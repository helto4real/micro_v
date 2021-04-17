module core

import lib.comp.symbols

pub fn (mut m AModule) add_standard_funcs() {
	m.add_longjmp_setjmp()
	m.declare_common_global_vars()
}

fn (mut m AModule) add_longjmp_setjmp() {
	// declare the jmp buffer
	// TODO: size depending on target
	jumb_buff_global_name := 'jmp_buf'
	jmp_buf_typ_ref := m.types['JumpBuffer']

	mut value_refs := [C.LLVMConstInt(m.get_llvm_type(symbols.i64_symbol), i64(0),
		bool_to_llvm_bool(false))]

	res := C.LLVMConstNamedStruct(jmp_buf_typ_ref, value_refs.data, value_refs.len)

	m.jmp_buff = C.LLVMAddGlobal(m.mod_ref, jmp_buf_typ_ref, jumb_buff_global_name.str)

	C.LLVMSetInitializer(m.jmp_buff, res)

	// jongjmp declaration
	// Argument type
	mut longjmp_function_args_type := []&C.LLVMTypeRef{}
	// Add the char* format
	longjmp_function_args_type << C.LLVMPointerType(jmp_buf_typ_ref, 0)
	longjmp_function_args_type << C.LLVMInt64TypeInContext(m.ctx_ref)
	// puts function
	longjmp_function_type := C.LLVMFunctionType(C.LLVMVoidTypeInContext(m.ctx_ref), longjmp_function_args_type.data,
		2, bool_to_llvm_bool(false))
	// Add puts
	func_typ_longjmp := C.LLVMAddFunction(m.mod_ref, 'longjmp', longjmp_function_type)
	m.built_in_funcs['longjmp'] = func_typ_longjmp

	// setjmp declaration
	// Argument type
	mut setjmp_function_args_type := []&C.LLVMTypeRef{}
	// Add the char* format
	setjmp_function_args_type << C.LLVMPointerType(jmp_buf_typ_ref, 0)
	// puts function
	setjmp_function_type := C.LLVMFunctionType(C.LLVMInt64TypeInContext(m.ctx_ref), setjmp_function_args_type.data,
		1, bool_to_llvm_bool(false))
	// Add puts
	func_typ_setjmp := C.LLVMAddFunction(m.mod_ref, 'setjmp', setjmp_function_type)
	m.built_in_funcs['setjmp'] = func_typ_setjmp
}

pub fn (mut m AModule) declare_common_global_vars() {
	// add the global sprintf buffer
	buff_typ := C.LLVMArrayType(C.LLVMInt8TypeInContext(m.ctx_ref), 21)
	name := 'sprintf_buff'
	buff_ref := C.LLVMAddGlobal(m.mod_ref, buff_typ, name.str)
	null_ref := C.LLVMConstNull(buff_typ)
	C.LLVMSetInitializer(buff_ref, null_ref)
	m.global_const[GlobalVarRefType.sprintf_buff] = buff_ref
}

pub fn (mut m AModule) get_standard_struct_types() []symbols.StructTypeSymbol {
	// declare the jumb_buf
	// Todo: size depending on target arch
	mut res := []symbols.StructTypeSymbol{}
	mut jmp_buf_symbol := symbols.new_struct_symbol('lib.runtime', 'JumpBuffer', false, false)
	jmp_buf_symbol.members << symbols.new_struct_type_member('', symbols.i64_symbol)
	res << jmp_buf_symbol

	return res
}
