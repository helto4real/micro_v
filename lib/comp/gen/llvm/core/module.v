module core

import term
import lib.comp.symbols
import lib.comp.binding

const (
	no_name = '\00'
)

pub enum GlobalVarRefType {
	printf_str
	printf_str_nl
	printf_num
	sprintf_buff
	str_true
	str_false
	nl
}

pub struct ABuilder {
mut:
	builder_ref &C.LLVMBuilderRef
}

pub fn new_llvm_builder(ctx_ref &C.LLVMContextRef) ABuilder {
	return ABuilder{
		builder_ref: C.LLVMCreateBuilderInContext(ctx_ref)
	}
}

pub fn (mut b ABuilder) free() {
	C.LLVMDisposeBuilder(b.builder_ref)
}

pub struct AModule {
	ctx_ref     &C.LLVMContextRef
	mod_ref     &C.LLVMModuleRef
	exec_engine &C.LLVMExecutionEngineRef = 0
mut:
	builder ABuilder
	funcs   []&Function
	// funcs_map      map[string]&Function
	built_in_funcs map[string]&C.LLVMValueRef
	main_func_ref  &C.LLVMValueRef = 0
	types          map[string]&C.LLVMTypeRef
	jmp_buff       &C.LLVMValueRef       = 0
	pass_ref       &C.LLVMPassManagerRef = 0
	global_const   map[GlobalVarRefType]&C.LLVMValueRef
pub mut:
	is_test bool
}

pub fn new_llvm_module(name string) AModule {
	ctx_ref := C.LLVMContextCreate()
	builder := new_llvm_builder(ctx_ref)
	mod_ref := C.LLVMModuleCreateWithNameInContext(name.str, ctx_ref)
	mut mod := AModule{
		ctx_ref: ctx_ref
		mod_ref: mod_ref
		builder: builder
	}
	mod.init_globals()
	return mod
}

fn (mut m AModule) init_globals() {
	// add standard structs

	standard_structs := m.get_standard_struct_types()
	for standard_struct in standard_structs {
		typ_ref := C.LLVMStructCreateNamed(m.ctx_ref, standard_struct.name.str)
		m.types[standard_struct.name] = typ_ref
		mut type_refs := []&C.LLVMTypeRef{}
		for member in standard_struct.members {
			type_ref := m.get_llvm_type(member.typ)
			if member.typ.is_ref {
				type_refs << C.LLVMPointerType(type_ref, 0)
			} else {
				type_refs << type_ref
			}
		}
		C.LLVMStructSetBody(typ_ref, type_refs.data, type_refs.len, bool_to_llvm_bool(false))
	}
	m.add_standard_funcs()
}

pub fn (mut m AModule) free() {
	if m.exec_engine != 0 {
		err := &char(0)
		// if exec engine exists we need to remove the module
		// before you can dispose the engine and the module		mut err := charptr(0)
		mut out_mod := voidptr(0)
		if C.LLVMRemoveModule(m.exec_engine, m.mod_ref, &out_mod, err) != 0 {
			panic('failed to remove module: $err')
		}
		C.LLVMDisposeExecutionEngine(m.exec_engine)
	}
	// Todo: Dispose engine
	m.builder.free()

	C.LLVMDisposeModule(m.mod_ref)
	C.LLVMContextDispose(m.ctx_ref)
}

pub fn (mut m AModule) init_jit_execution_engine() ? {
	C.LLVMLinkInMCJIT()
	if C.LLVMInitializeNativeTarget() != 0 {
		return error('Failed to init the native target')
	}

	if C.LLVMInitializeNativeAsmPrinter() != 0 {
		return error('Failed to init the native printer')
	}

	if C.LLVMInitializeNativeAsmParser() != 0 {
		return error('Failed to init the native parser')
	}
	err_msg := &char(0)
	if C.LLVMCreateMCJITCompilerForModule(&m.exec_engine, m.mod_ref, voidptr(0), 0, err_msg) != 0 {
		// TODO: LLVMDisposeMessage
		return error('failed to create jit compiler for module: $err_msg')
	}
	return none
}

pub fn (mut m AModule) run_main() i64 {
	m.init_jit_execution_engine() or { panic('error init execution enging : $err.msg') }
	if m.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	args := []&C.LLVMGenericValueRef{}
	res := C.LLVMRunFunction(m.exec_engine, m.main_func_ref, 0, args.data)
	return i64(C.LLVMGenericValueToInt(res, core.bool_to_llvm_bool(true)))
}

fn compare_function_by_file_and_name(a &Function, b &Function) int {
	if a.func.location.source.filename == b.func.location.source.filename {
		if a.func.name < b.func.name {
			return -1
		} else {
			return 1
		}
	}

	if a.func.location.source.filename < b.func.location.source.filename {
		return -1
	}
	return 1
}

pub fn (mut m AModule) run_tests() bool {
	m.init_jit_execution_engine() or { panic('error init execution enging : $err.msg') }
	if m.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	mut test_funcs := []Function{}
	for func in m.funcs {
		if func.func.name.starts_with('test_') {
			test_funcs << func
		}
	}

	test_funcs.sort_with_compare(compare_function_by_file_and_name)

	// run main to be sure it is jit
	main_args := []&C.LLVMGenericValueRef{}
	C.LLVMRunFunction(m.exec_engine, m.main_func_ref, 0, main_args.data)

	mut nr_of_tests := 0
	mut nr_of_errors := 0
	mut current_file_has_errors := false
	mut current_file := ''
	mut total_nr_of_test_files := 0

	for func in test_funcs {
		if func.func.location.source.filename != current_file {
			total_nr_of_test_files++
			current_file = func.func.location.source.filename
		}
	}
	current_file = ''
	println('------------------------------ test ------------------------------')
	for func in test_funcs {
		if func.func.location.source.filename != current_file {
			if current_file.len > 0 {
				print_result(current_file, !current_file_has_errors, nr_of_tests, total_nr_of_test_files)
			}
			current_file = func.func.location.source.filename
			current_file_has_errors = false
			nr_of_tests++
		}
		args := []&C.LLVMGenericValueRef{}
		res := C.LLVMRunFunction(m.exec_engine, func.func_ref, 0, args.data)
		int_res := C.LLVMGenericValueToInt(res, core.bool_to_llvm_bool(true))
		if int_res == 0 {
		} else {
			current_file_has_errors = true
			nr_of_errors++
		}
	}
	print_result(current_file, !current_file_has_errors, nr_of_tests, total_nr_of_test_files)

	println('------------------------------------------------------------------')
	return nr_of_errors == 0
}

fn print_result(filename string, is_ok bool, test_nr int, total_nr_of_tests int) {
	print('   ')
	if is_ok {
		print(term.green(' OK   '))
	} else {
		print(term.fail_message('FAIL'))
	}
	print(' [')
	total_nr_of_digits_total := nr_of_digits(total_nr_of_tests)
	total_nr_of_digits_test_nr := nr_of_digits(test_nr)
	leading_zeros := total_nr_of_digits_total - total_nr_of_digits_test_nr
	if leading_zeros > 0 {
		print('0'.repeat(leading_zeros))
	}
	print('$test_nr/$total_nr_of_tests]  ')
	println(filename)
}

fn nr_of_digits(n int) int {
	mut total := 0
	for i := 1; i <= n; i *= 10 {
		total++
	}
	return total
}

pub fn (mut m AModule) verify() ? {
	mut err := &char(0)
	res := C.LLVMVerifyModule(m.mod_ref, .llvm_abort_process_action, err)

	if llvm_bool_to_bool(res) {
		unsafe {
			return error(err.vstring())
		}
	}
	return none
}

pub fn (mut m AModule) optimize() {
	m.pass_ref = C.LLVMCreatePassManager()
	C.LLVMAddInternalizePass(m.pass_ref, 1)
	// C.LLVMAddAggressiveDCEPass(m.pass_ref)
	C.LLVMAddDCEPass(m.pass_ref)
	C.LLVMAddInstructionCombiningPass(m.pass_ref)
	C.LLVMAddReassociatePass(m.pass_ref)
	C.LLVMAddGVNPass(m.pass_ref)
	C.LLVMAddGlobalDCEPass(m.pass_ref)
	C.LLVMRunPassManager(m.pass_ref, m.mod_ref)
}

pub fn (mut m AModule) add_global_string_literal_ptr(str_val string) &C.LLVMValueRef {
	return C.LLVMBuildGlobalStringPtr(m.builder.builder_ref, &char(str_val.str), &char(core.no_name.str))
}

pub fn (mut m AModule) add_global_struct_const_ptr(typ_ref &C.LLVMTypeRef, val_ref &C.LLVMValueRef) &C.LLVMValueRef {
	val := C.LLVMBuildStructGEP2(m.builder.builder_ref, typ_ref, val_ref, 0, core.no_name.str)
	return val
}

pub fn (m AModule) print_to_file(path string) ? {
	mut err := &char(0)
	res := C.LLVMPrintModuleToFile(m.mod_ref, path.str, err)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path, $err.vstring()')
		}
	}
	return none
}

pub fn (m AModule) write_to_file(path string) ? {
	res := C.LLVMWriteBitcodeToFile(m.mod_ref, path.str)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path')
		}
	}
	return none
}

pub fn (mut m AModule) generate_module(program &binding.BoundProgram, is_test bool) {
	m.is_test = is_test

	// first declare struct names
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			mut struct_name := typ.name
			if typ.is_c_decl && typ.members.len == 0 {
				// remove the C. in the name when whe have opaque type
				// defined in a library
				name_parts := struct_name.split('.')
				struct_name = name_parts[name_parts.len-1]
			}
			typ_ref := C.LLVMStructCreateNamed(m.ctx_ref, struct_name.str)
			m.types[typ.name] = typ_ref
		}
	}
	
	// first declare all C function declares
	for func in program.func_symbols {
		if func.is_c_decl {
			m.declare_function(func, binding.new_empty_block_stmt())
		}
	}


	// then declare struct body
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			struct_type_ref := m.get_llvm_type(typ)
			mut type_refs := []&C.LLVMTypeRef{}
			for member in typ.members {
				type_ref := m.get_llvm_type(member.typ)
				if member.typ.is_ref {
					type_refs << C.LLVMPointerType(type_ref, 0)
				} else {
					type_refs << type_ref
				}
			}
			if type_refs.len > 0 {
				C.LLVMStructSetBody(struct_type_ref, type_refs.data, type_refs.len, bool_to_llvm_bool(false))
			}
		}
	}

	if is_test == false {
		body := program.func_bodies[program.main_func.id] or {
			// No main defined or global statements
			panic('unexpected, function body for $program.main_func.name ($program.main_func.id) missing')
		}
		lowered_body := binding.lower(body)
		m.declare_function(program.main_func, lowered_body)
	} else {
		test_main := symbols.new_function_symbol('main', 'main', []symbols.ParamSymbol{},
			symbols.int_symbol)
		body := binding.new_bound_block_stmt([]binding.BoundStmt{})
		m.declare_function(test_main, body)
	}

	// first declare all functions except the main and C declares
	for func in program.func_symbols {
		if func.name != 'main' && !func.is_c_decl {
			// this is a normal function, expect a body
			body := program.func_bodies[func.id] or {
				panic('unexpected, function body for $func.name ($func.id) missing')
			}
			lowered_body := binding.lower(body)
			m.declare_function(func, lowered_body)
		}
	}

	// generate bodies of all functions
	// First generate main body
	for f in m.funcs {
		mut ff := f
		if ff.func.name == 'main' {
			ff.generate_function_bodies()
		}
	}

	// generate bodies of all rest of the functions

	for f in m.funcs {
		mut ff := f
		if ff.func.name != 'main' && !ff.func.is_c_decl {
			ff.generate_function_bodies()
		}
	}
}

pub fn (mut m AModule) declare_function(func symbols.FunctionSymbol, body binding.BoundBlockStmt) {
	f := new_llvm_func(m, func, body)
	if func.is_c_decl {
		// if it is a C decl, add it to built_in_funcs
		m.built_in_funcs[f.name] = f.func_ref
		m.funcs << f
	} else {
		// m.funcs_map[func.id] = f
		m.funcs << f
	}

	if func.name == 'main' {
		m.main_func_ref = f.func_ref
	}
}

fn (m &AModule) get_llvm_type(typ symbols.TypeSymbol) &C.LLVMTypeRef {
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.kind {
				.int_symbol {
					return C.LLVMInt32TypeInContext(m.ctx_ref)
				}
				.i64_symbol {
					return C.LLVMInt64TypeInContext(m.ctx_ref)
				}
				.bool_symbol {
					return C.LLVMInt1TypeInContext(m.ctx_ref)
				}
				.string_symbol {
					return C.LLVMPointerType(C.LLVMInt8TypeInContext(m.ctx_ref), 0)
				}
				.byte_symbol {
					return C.LLVMInt8TypeInContext(m.ctx_ref)
				}
				.char_symbol {
					return C.LLVMInt8TypeInContext(m.ctx_ref)
				}
				else {
					panic('unexpected, unsupported built-in type: $typ')
				}
			}
		}
		symbols.ArrayTypeSymbol {
			elem_typ_ref := m.get_llvm_type(typ.elem_typ)
			return C.LLVMArrayType(elem_typ_ref, typ.len)
		}
		symbols.VoidTypeSymbol {
			return C.LLVMVoidTypeInContext(m.ctx_ref)
		}
		symbols.StructTypeSymbol {
			return m.types[typ.name] or { panic('unexpected, type $typ not found in symols table ${m.types.keys()}') }
		}
		else {
			panic('unexpected, unsupported type ref $typ, $typ.kind')
		}
	}

	panic('unexpected, unsupported type: $typ')
}
