module core

import lib.comp.symbols
import lib.comp.binding

const (
	no_name = '\00'
)

pub enum GlobalVarRefType {
	printf_str
	printf_str_nl
}

pub struct Builder {
mut:
	builder_ref &C.LLVMBuilderRef
}

pub fn new_llvm_builder(ctx_ref &C.LLVMContextRef) Builder {
	return Builder{
		builder_ref: C.LLVMCreateBuilderInContext(ctx_ref)
	}
}

pub fn (mut b Builder) free() {
	C.LLVMDisposeBuilder(b.builder_ref)
}

pub struct Module {
	ctx_ref     &C.LLVMContextRef
	mod_ref     &C.LLVMModuleRef
	exec_engine &C.LLVMExecutionEngineRef = 0
mut:
	builder        Builder
	funcs          map[string]Function
	built_in_funcs map[string]&C.LLVMValueRef
	main_func_ref  &C.LLVMValueRef = 0
	types          map[string]&C.LLVMTypeRef
	jmp_buff	   &C.LLVMValueRef = 0

	global_const map[GlobalVarRefType]&C.LLVMValueRef
}

pub fn new_llvm_module(name string) Module {
	ctx_ref := C.LLVMContextCreate()
	builder := new_llvm_builder(ctx_ref)
	mod_ref := C.LLVMModuleCreateWithNameInContext(name.str, ctx_ref)
	mut mod := Module{
		ctx_ref: ctx_ref
		mod_ref: mod_ref
		builder: builder
	}
	mod.init_globals()
	return mod
}

fn (mut m Module) init_globals() {
		// add standard structs

	standard_structs := m.get_standard_struct_types()
	for standard_struct in standard_structs {
		typ_ref := C.LLVMStructCreateNamed(m.ctx_ref, standard_struct.name.str)
		m.types[standard_struct.name] = typ_ref
		mut type_refs := []&C.LLVMTypeRef{}
		for member in standard_struct.members {
			type_refs << get_llvm_type_ref(member.typ, m)
		}
		C.LLVMStructSetBody(typ_ref, type_refs.data, type_refs.len, 0)
	}
	m.add_standard_funcs()
}

pub fn (mut m Module) free() {
	if m.exec_engine != 0 {
		err := charptr(0)
		// if exec engine exists we need to remove the module
		// before you can dispose the engine and the module		mut err := charptr(0)
		mut out_mod := voidptr(0)
		if C.LLVMRemoveModule(m.exec_engine, m.mod_ref, &out_mod, &err) != 0 {
			panic('failed to remove module: $err')
		}
	}
	// Todo: Dispose engine 
	m.builder.free()

	C.LLVMDisposeModule(m.mod_ref)
	C.LLVMDisposeExecutionEngine(m.exec_engine)
	C.LLVMContextDispose(m.ctx_ref)
}

pub fn (mut m Module) init_jit_execution_engine() ? {
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
	err_msg := charptr(0)
	if C.LLVMCreateMCJITCompilerForModule(&m.exec_engine, m.mod_ref, voidptr(0), 0, &err_msg) != 0 {
		// TODO: LLVMDisposeMessage
		return error('failed to create jit compiler for module: $err_msg')
	}
	return none
}

pub fn (mut m Module) run_main() i64 {
	m.init_jit_execution_engine() or { panic('error init execution enging : $err.msg') }
	if m.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	args := []&C.LLVMGenericValueRef{}
	res := C.LLVMRunFunction(m.exec_engine, m.main_func_ref, 0, args.data)
	return i64(C.LLVMGenericValueToInt(res, 1))
}

pub fn (mut m Module) run_tests() bool {
	m.init_jit_execution_engine() or { panic('error init execution enging : $err.msg') }
	if m.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	mut test_funcs := []Function{}
	for _, f in m.funcs {
		if f.func.name.starts_with('test_') {
			test_funcs << f
		}
	}
	test_funcs.sort(a.func.name < b.func.name)

	// run main to be sure it is jit
	main_args := []&C.LLVMGenericValueRef{}
	C.LLVMRunFunction(m.exec_engine, m.main_func_ref, 0, main_args.data)


	mut nr_of_tests := 0 
	mut nr_of_errors := 0 

	for func in test_funcs {
		args := []&C.LLVMGenericValueRef{}
		res := C.LLVMRunFunction(m.exec_engine, func.func_ref, 0, args.data)
		int_res := C.LLVMGenericValueToInt(res, 1) 
		nr_of_tests++
		if int_res == 0 {

		} else {
			nr_of_errors++
		}
	}
	return nr_of_errors ==  0
}

pub fn (mut m Module) verify() ? {
	mut err := charptr(0)
	res := C.LLVMVerifyModule(m.mod_ref, .llvm_abort_process_action, &err)

	if res != 0 || err != 0 {
		unsafe {
			return error(err.vstring())
		}
	}
	return none
}

pub fn (mut m Module) add_global_string_literal_ptr(str_val string) &C.LLVMValueRef {
	return C.LLVMBuildGlobalStringPtr(m.builder.builder_ref, charptr(str_val.str), charptr(core.no_name.str))
}

pub fn (mut m Module) add_global_struct_const_ptr(typ_ref &C.LLVMTypeRef, val_ref &C.LLVMValueRef) &C.LLVMValueRef {
	val :=  C.LLVMBuildStructGEP2(m.builder.builder_ref, typ_ref,
                                val_ref, 0,
                                no_name.str)
	return val
}

pub fn (m Module) print_to_file(path string) ? {
	mut err := charptr(0)
	res := C.LLVMPrintModuleToFile(m.mod_ref, path.str, &err)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path, $err.vstring()')
		}
	}
	return none
}


pub fn (mut m Module) generate_module(program &binding.BoundProgram, is_test bool) {


	// first declare struct names
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			typ_ref := C.LLVMStructCreateNamed(m.ctx_ref, typ.name.str)
			m.types[typ.id] = typ_ref
		}
	}

	// then declare struct body
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			struct_type_ref := get_llvm_type_ref(typ, m)
			mut type_refs := []&C.LLVMTypeRef{}
			for member in typ.members {
				type_refs << get_llvm_type_ref(member.typ, m)
			}
			C.LLVMStructSetBody(struct_type_ref, type_refs.data, type_refs.len, 0)
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
		test_main := symbols.new_function_symbol('main', []symbols.ParamSymbol{}, symbols.int_symbol)
		body := binding.new_bound_block_stmt([]binding.BoundStmt{})
		m.declare_function(test_main, body)
	}	

	// first declare all functions except the main
	for func in program.func_symbols {
		if func.name != 'main' {
			body := program.func_bodies[func.id] or {
				panic('unexpected, function body for $func.name ($func.id) missing')
			}
			lowered_body := binding.lower(body)
			m.declare_function(func, lowered_body)
		}
	}

	// generate bodies of all functions
	// First generate main body
	for _, mut func in m.funcs {
		if func.func.name == 'main' {
			func.generate_function_bodies()
		}
	}
	// generate bodies of all rest of the functions
	for _, mut func in m.funcs {
		if func.func.name != 'main' {
			func.generate_function_bodies()
		}
	}
}

pub fn (mut m Module) declare_function(func symbols.FunctionSymbol, body binding.BoundBlockStmt) {
	f := new_llvm_func(m, func, body)
	m.funcs[func.id] = f

	if func.name == 'main' {
		m.main_func_ref = f.func_ref
	}
}
