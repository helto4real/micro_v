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
	funcs          []Function
	built_in_funcs map[string]&C.LLVMValueRef
	main_func_ref  &C.LLVMValueRef = 0

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

pub fn (mut m Module) run_main() {
	m.init_jit_execution_engine() or { panic('error init execution enging : $err.msg') }
	if m.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	args := []&C.LLVMGenericValueRef{}
	C.LLVMRunFunction(m.exec_engine, m.main_func_ref, 0, args.data)
}

pub fn (mut m Module) verify() ? {
	mut err := charptr(0)
	res := C.LLVMVerifyModule(m.mod_ref, .llvm_abort_process_action, &err)

	if res != 0 {
		unsafe {
			return error(err.vstring())
		}
	}
	return none
}

pub fn (mut m Module) add_global_string_literal_ptr(str_val string) &C.LLVMValueRef {
	return C.LLVMBuildGlobalStringPtr(m.builder.builder_ref, charptr(str_val.str), charptr(core.no_name.str))
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

pub fn (mut m Module) declare_function(func symbols.FunctionSymbol, body binding.BoundBlockStmt) {
	f := new_llvm_func(m, func, body)
	m.funcs << f

	if func.name == 'main' {
		m.main_func_ref = f.llvm_func
	}
}