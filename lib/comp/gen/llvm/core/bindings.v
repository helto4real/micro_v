module core
// All main enities has V corresponding structs
pub struct Context {
pub:
	c &C.LLVMContextRef
}

pub struct Module {
pub:
	c &C.LLVMModuleRef
}

pub struct Type {
pub:
	c &C.LLVMTypeRef
}

pub struct Value {
pub:
	c &C.LLVMValueRef
}

pub struct GenericValue {
pub:
	c &C.LLVMGenericValueRef
}

pub struct BasicBlock {
pub:
	c &C.LLVMBasicBlockRef
}

pub struct Builder {
pub:
	c &C.LLVMBuilderRef
}
pub struct PassManager {
pub:
	c &C.LLVMPassManagerRef
}
pub fn (c PassManager) str() string { return 'PassManager ($c.c)'}

pub struct Use  {
pub:
	c &C.LLVMUseRef
}
pub fn (c Use) str() string { return 'Use ($c.c)'}

pub fn (l Type) isnil() bool {return l.c==0}
pub fn (l Value) isnil() bool {return l.c==0}
pub fn (l BasicBlock) isnil() bool {return l.c==0}
pub fn (l Builder) isnil() bool {return l.c==0}
pub fn (l PassManager) isnil() bool {return l.c==0}


pub fn new_context() Context {
	return Context {
		c: C.LLVMContextCreate()
	}
}


pub fn new_global_context() Context {
	return Context {
		c: C.LLVMGetGlobalContext()
	}
}

pub fn (l Type) type_ref() &C.LLVMTypeRef {return l.c}
pub fn (l Value) value_ref() &C.LLVMValueRef {return l.c}

pub fn bool_to_llvm_bool(b bool) C.LLVMBool {
	if b {
		return C.LLVMBool(1)
	}
	return C.LLVMBool(0)
}

pub fn llvm_bool_to_bool(b C.LLVMBool) bool {
	if b == C.LLVMBool(0) {
		return false
	}
	return true
}

// modules 

pub fn new_module(name string) Module {
	return Module {
		c: C.LLVMModuleCreateWithName(name.str)
	}
}
pub fn (c Context) new_module(name string) Module {
	return Module {
		c: C.LLVMModuleCreateWithNameInContext(name.str, c.c)
	}
}

pub fn (c Context) new_builder() Builder {
	return Builder {
		c: C.LLVMCreateBuilderInContext(c.c)
	}
}

pub fn (m Context) dispose() {
	if m.c != 0 {
		C.LLVMContextDispose(m.c)
	}
}

pub fn (m Module) dispose() {
	if m.c != 0 {
		C.LLVMDisposeModule(m.c)
	}
}

pub fn (m Module) add_global(name string, typ Type) Value {
	return Value {
		c: C.LLVMAddGlobal(m.c, typ.c, name.str)
	}	
}

pub fn (m Module) get_type_by_name(name string) Type {
	return Type {
		c: C.LLVMGetTypeByName(m.c, name.str)
	}
}

pub fn (m Module) dump_module() {
	C.LLVMDumpModule(m.c)
}

pub fn (m Module) context() Context {
	return Context {
		c: C.LLVMGetModuleContext(m.c)
	}
}

pub fn (m Module) add_function(name string, fn_typ Type) Value {
	return Value {
		c: C.LLVMAddFunction(m.c, name.str, fn_typ.c)
	}
}

pub fn (m Module) create_mc_jit_compiler() ? &ExecutionEngine {
	err_msg := &char(0)
	ee :=  &ExecutionEngine {}
	if C.LLVMCreateMCJITCompilerForModule(&ee.c, m.c, voidptr(0), 0, err_msg) != 0 {
		// TODO: LLVMDisposeMessage
		return error('failed to create jit compiler for module: $err_msg')
	}
	return ee
}

pub fn (m Module) print_to_file(path string) ? {
	mut err := &char(0)
	res := C.LLVMPrintModuleToFile(m.c, path.str, err)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path, $err.vstring()')
		}
	}
	return none
}

pub fn (m Module) write_to_file(path string) ? {
	res := C.LLVMWriteBitcodeToFile(m.c, path.str)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path')
		}
	}
	return none
}	

pub fn (mut m Module) verify() ? {
	mut err := &char(0)
	res := C.LLVMVerifyModule(m.c, .llvm_abort_process_action, err)
	if llvm_bool_to_bool(res) || err != 0 {
		unsafe {
			return error(err.vstring())
		}
	}
}


pub fn (t Type) type_kind() LLVMTypeKind {return C.LLVMGetTypeKind(t.c)}
pub fn (t Type) conext() Context {
	return Context {
		c: C.LLVMGetTypeContext(t.c)
	}
}

pub fn (t Type) int_type_width() int {
	return C.LLVMGetIntTypeWidth(t.c)
}


// context
pub fn (c Context) int1_type() Type {return Type{c: C.LLVMInt1TypeInContext(c.c)}}
pub fn (c Context) int8_type() Type {return Type{c: C.LLVMInt8TypeInContext(c.c)}}
pub fn (c Context) int16_type() Type {return Type{c: C.LLVMInt16TypeInContext(c.c)}}
pub fn (c Context) int32_type() Type {return Type{c: C.LLVMInt32TypeInContext(c.c)}}
pub fn (c Context) int64_type() Type {return Type{c: C.LLVMInt64TypeInContext(c.c)}}
pub fn (c Context) int_type(bits int) Type {
	return Type{
		c: C.LLVMIntTypeInContext(c.c, bits)
	}
}
pub fn (c Context) void_type() Type {return Type{c: C.LLVMVoidTypeInContext(c.c)}}

pub fn int1_type() Type  { return Type { c: C.LLVMInt1Type() } }
pub fn int8_type() Type  { return Type { c: C.LLVMInt8Type() } }
pub fn int16_type() Type { return Type { c: C.LLVMInt16Type() } }
pub fn int32_type() Type { return Type { c: C.LLVMInt32Type() } }
pub fn int64_type() Type { return Type { c: C.LLVMInt64Type() } }

pub fn void_type() Type {return Type{c: C.LLVMVoidType()}}


// functions
pub fn new_function_type(ret_type Type, param_types []Type, is_variadic bool) Type {
	c_param_types := type_refs(param_types)

	ft := C.LLVMFunctionType(ret_type.c,
		c_param_types.data,
		c_param_types.len,
		bool_to_llvm_bool(is_variadic))
	
	return Type {c: ft}
}

pub fn (t Type) create_const_array(const_values []Value) Value { 
	c_values := value_refs(const_values)
	return Value { c: C.LLVMConstArray(t.c, c_values.data, c_values.len)} 
}

pub fn (t Type) create_const_named_struct(const_values []Value) Value { 
	c_values := value_refs(const_values)
	return Value { c: C.LLVMConstNamedStruct(t.c, c_values.data, c_values.len)} 
}
pub fn (t Type) add_function(name string, mod Module) Value {
	return Value {
		c: C.LLVMAddFunction(mod.c, name.str, t.c)
	}
}
pub fn (t Type) is_fn_var_arg() bool { return C.LLVMIsFunctionVarArg(t.c) != C.LLVMBool(0) }
pub fn (t Type) return_type() Type  { return Type { c: C.LLVMGetReturnType(t.c) } }
pub fn (t Type) params_typ_count() int   { return C.LLVMCountParamTypes(t.c) }
pub fn (t Type) const_ptr_null() Value   { return Value { c: C.LLVMConstPointerNull(t.c) }}
pub fn (t Type) const_null() Value   { return Value { c: C.LLVMConstNull(t.c) }}
// pub fn (t Type) param_types() []Type {
// 	count := t.ParamTypesCount()
// 	types := []Type{cap:count}
// 	if count > 0 {
// 		out := make([]Type, count)
// 		C.LLVMGetParamTypes(t.C, llvmTypeRefPtr(&out[0]))
// 		return out
// 	}
// 	return nil
// }

pub fn (t Type) to_array_type(count int) Type {
	return new_array_type(t, count)
}

pub fn (t Type) array_len() int {
	return C.LLVMGetArrayLength(t.c)
}

pub fn (t Type) to_pointer_type(address_space int) Type {
	return new_pointer_type(t, address_space)
}

pub fn (t Type) element_type() Type {
	return Type {
		c: C.LLVMGetElementType(t.c)
	}
}

pub fn type_refs(types []Type) []&C.LLVMTypeRef {
	mut c_types := []&C.LLVMTypeRef{}
	for t in types {
		c_types << t.c
	}
	return c_types
}

// Structs

pub fn (c Context) new_struct_type(element_types []Type, packed bool) Type {
	types := type_refs(element_types)

	struct_typ := C.LLVMStructTypeInContext(c.c,
		types.data,
		types.len,
		bool_to_llvm_bool(packed))

	return Type {
		c: struct_typ
	}
}

pub fn (c Context) new_named_struct_type(name string) Type {
	return Type {
		c:  C.LLVMStructCreateNamed(c.c, name.str)
	}
}

pub fn (t Type) struct_set_body(element_types []Type, packed bool) {
	types := type_refs(element_types)
	C.LLVMStructSetBody(t.c, types.data, types.len, bool_to_llvm_bool(packed))
}

// arrays

pub fn new_array_type(element_type Type, count int) Type {
	return Type {
		c: C.LLVMArrayType(element_type.c, count)
	}
}


// pointers
pub fn new_pointer_type(element_type Type, address_space int) Type {
	return Type {
		c: C.LLVMPointerType(element_type.c, address_space)
	}
}

// basic block

pub fn (c Context) new_basic_block(fn_val Value, name string) BasicBlock {
	return BasicBlock {
		c: C.LLVMAppendBasicBlockInContext(c.c, fn_val.c, name.str)
	}
}

pub fn (c Context) insert_basic_block(bb BasicBlock, name string) BasicBlock {
	return BasicBlock {
		c: C.LLVMInsertBasicBlockInContext(c.c, bb.c, name.str)
	}
}
pub fn new_basic_block(name string, fn_val Value) BasicBlock {
	return BasicBlock {
		c: C.LLVMAppendBasicBlock(fn_val.c, name.str)
	}	
}
pub fn (bb BasicBlock) move_before(pos BasicBlock)  {
	C.LLVMMoveBasicBlockBefore(bb.c, pos.c)
}

pub fn (bb BasicBlock) move_after(pos BasicBlock)  {
	C.LLVMMoveBasicBlockAfter(bb.c, pos.c)
}

pub fn (bb BasicBlock) last_instruction() Value {
	return Value {
		c: C.LLVMGetLastInstruction(bb.c) 
	}
}

// values
pub fn (v Value) value_kind() LLVMValueKind {return C.LLVMGetValueKind(v.c)}
pub fn (v Value) typ() Type {return Type{ c: C.LLVMTypeOf(v.c)}}
pub fn (v Value) dump_value() { C.LLVMDumpValue(v.c) }

pub fn (v Value) is_a_argument() Value { return Value { c: C.LLVMIsAArgument(v.c) }}
pub fn (v Value) is_a_terminator_instruction() Value { return Value { c: C.LLVMIsATerminatorInst(v.c) }}
pub fn (v Value) is_constant() bool   { return llvm_bool_to_bool(C.LLVMIsConstant(v.c)) }
pub fn (v Value) is_null() bool  { return llvm_bool_to_bool(C.LLVMIsNull(v.c)) }
pub fn (v Value) set_initializer(val Value) { C.LLVMSetInitializer(v.c, val.c) }

pub fn (v Value) param(index int) Value { return Value { c: C.LLVMGetParam(v.c, index) }}

pub fn (v Value) first_use() Use { return Use {c :C.LLVMGetFirstUse(v.c)}}
pub fn (u Use) next_use() Use { return Use {c :C.LLVMGetNextUse(u.c)}}

pub fn value_refs(values []Value) []&C.LLVMValueRef {
	mut c_values := []&C.LLVMValueRef{}
	for t in values {
		c_values << t.c
	}
	return c_values
}

// constants
pub fn const_int(t Type, val u64, sign_extend bool) Value {
	return Value {
		c: C.LLVMConstInt(t.c,
		val,
		bool_to_llvm_bool(sign_extend))
	}
}

pub fn (c Context) c_i1(val int, sign_extend bool) Value { return const_int(c.int1_type(), u64(val), sign_extend) }
pub fn (c Context) c_i8(val int, sign_extend bool) Value { return const_int(c.int8_type(), u64(val), sign_extend) }
pub fn (c Context) c_i16(val int, sign_extend bool) Value { return const_int(c.int16_type(), u64(val), sign_extend) }
pub fn (c Context) c_i32(val int, sign_extend bool) Value { return const_int(c.int32_type(), u64(val), sign_extend) }
pub fn (c Context) c_i64(val u64, sign_extend bool) Value { return const_int(c.int64_type(), val, sign_extend) }

// builder

pub fn (b Builder) dispose() {
	if b.c != 0 {
		C.LLVMDisposeBuilder(b.c)
	}
}
pub fn (b Builder) position_at_end(bb BasicBlock) {
	C.LLVMPositionBuilderAtEnd(b.c, bb.c)
}

pub fn (b Builder) create_icmp(pred IntPredicate, lhs Value, rhs Value) Value {
	return Value {
		c: C.LLVMBuildICmp(b.c, pred, lhs.c, rhs.c, no_name.str)
	}
}

pub fn (b Builder) create_ret(val Value) Value {
	return Value {
		c: C.LLVMBuildRet(b.c, val.c)
	}
}

pub fn (b Builder) create_ret_void() Value {
	return Value {
		c: C.LLVMBuildRetVoid(b.c)
	}
}

pub fn (b Builder) create_unreachable() Value {
	return Value {
		c: C.LLVMBuildUnreachable(b.c)
	}
}

pub fn (b Builder) create_call2(fn_typ Type, fn_val Value, args []Value) Value {
	return Value {
		c: C.LLVMBuildCall2(b.c, fn_typ.c, fn_val.c, args.data,
			args.len, no_name.str)
	}
}

pub fn (b Builder) create_cond_br(val Value, then_block BasicBlock, else_block BasicBlock) Value {
	return Value {
		c: C.LLVMBuildCondBr(b.c, val.c, then_block.c, else_block.c)
	}
}

pub fn (b Builder) create_br(bb BasicBlock) Value {
	return Value {
		c: C.LLVMBuildBr(b.c, bb.c)
	}
}

pub fn (b Builder) create_int_to_ptr(val Value, typ Type) Value {
	return Value {
		c: C.LLVMBuildIntToPtr(b.c, val.c, typ.c, no_name.str)
	}
}

pub fn (b Builder) create_ptr_cast(val Value, typ Type) Value {
	return Value {
		c: C.LLVMBuildPointerCast(b.c, val.c, typ.c, no_name.str)
	}
}

pub fn (b Builder) create_global_string_ptr(str string, name string) Value {
	return Value {
		c: C.LLVMBuildGlobalStringPtr(b.c, str.str, name.str)
	}
}

pub fn (b Builder) create_load2(typ Type, val Value) Value {
	return Value {
		c: C.LLVMBuildLoad2(b.c, typ.c, val.c, no_name.str)
	}
}

pub fn (b Builder) create_int_cast(val Value, typ Type, is_signed bool) Value {
	return Value {
		c: C.LLVMBuildIntCast2(b.c, val.c, typ.c, bool_to_llvm_bool(is_signed), no_name.str)
	}
}

pub fn (b Builder) create_gep2(typ Type, val Value, indicies []Value) Value {
	return Value {
		c: C.LLVMBuildInBoundsGEP2(b.c, typ.c, val.c, indicies.data,
				indicies.len, no_name.str)
	}
}

pub fn (b Builder) create_bin_op(op Opcode, left_val Value, right_val Value) Value {
	return Value {
		c: C.LLVMBuildBinOp(b.c, op, left_val.c, right_val.c, no_name.str)
	}
}

pub fn (b Builder) create_neg(val Value) Value {
	return Value {
		c: C.LLVMBuildNeg(b.c, val.c, no_name.str)
	}
}

pub fn (b Builder) create_not(val Value) Value {
	return Value {
		c: C.LLVMBuildNot(b.c, val.c, no_name.str)
	}
}

pub fn (b Builder) alloca_and_store(typ Type, val Value, name string) Value {
	alloca_val := C.LLVMBuildAlloca(b.c, typ.c, name.str)
	C.LLVMBuildStore(b.c, val.c, alloca_val)
	return Value {
		c: alloca_val
	}
}

pub fn (b Builder) create_alloca(typ Type, name string) Value {
	return Value {
		c: C.LLVMBuildAlloca(b.c, typ.c, name.str)
	}
}

pub fn (b Builder) create_store(val Value, to_val Value) Value {
	return Value {
		c: C.LLVMBuildStore(b.c, val.c, to_val.c)
	}
}

// pub fn (b Builder) dispose() {
// 	if b.c != 0 {
// 		C.LLVMDisposeBuilder(b.c)
// 	}
// }

// execution engine
pub struct ExecutionEngine {
pub mut:
	c &C.LLVMExecutionEngineRef = 0
}

pub fn (ee ExecutionEngine) remove_module(mod Module) ? {
	err := &char(0)
	mut out_mod := voidptr(0)
	if C.LLVMRemoveModule(ee.c, mod.c, &out_mod, err) != 0 {
		return error('failed to remove module: $err')
	}
}

pub fn generic_value_refs(values []GenericValue) []&C.LLVMGenericValueRef {
	mut c_values := []&C.LLVMGenericValueRef{}
	for t in values {
		c_values << t.c
	}
	return c_values
}

pub fn (ee ExecutionEngine) run_function(fn_val Value, args ...GenericValue) GenericValue {
	args_ref := generic_value_refs(args)
	return GenericValue {
		c: C.LLVMRunFunction(ee.c, fn_val.c, args_ref.len, args_ref.data)
	}
	 
}

pub fn (ee ExecutionEngine) dispose() {
	C.LLVMDisposeExecutionEngine(ee.c)
}

pub fn link_in_mc_jit() {C.LLVMLinkInMCJIT()}
pub fn initialize_native_target() {C.LLVMInitializeNativeTarget()}
pub fn initialize_native_asm_printer() {C.LLVMInitializeNativeAsmPrinter()}
pub fn initialize_native_asm_parser() {C.LLVMInitializeNativeAsmParser()}


pub fn (gv GenericValue) int(signed bool) u64 {
	return C.LLVMGenericValueToInt(gv.c, bool_to_llvm_bool(signed))
}

// passes functions

pub fn new_pass_manager() &PassManager {
	return &PassManager {
		c: C.LLVMCreatePassManager()
	}
}

pub fn (l PassManager) add_internalize_pass() {
	C.LLVMAddInternalizePass(l.c, 1)
}
pub fn (l PassManager) add_dce_pass() {
	C.LLVMAddDCEPass(l.c)
}
pub fn (l PassManager) add_instruction_combining_pass() {
	C.LLVMAddInstructionCombiningPass(l.c)
}
pub fn (l PassManager) add_reassociate_pass() {
	C.LLVMAddReassociatePass(l.c)
}
pub fn (l PassManager) add_gvn_pass() {
	C.LLVMAddGVNPass(l.c)
}
pub fn (l PassManager) add_global_dce_pass() {
	C.LLVMAddGlobalDCEPass(l.c)
}
pub fn (l PassManager) run_pass_manager(mod Module) {
	C.LLVMRunPassManager(l.c, mod.c)
}
