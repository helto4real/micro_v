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
	builder_ref C.LLVMBuilderRef
}

pub fn new_llvm_builder(ctx_ref C.LLVMContextRef) Builder {
	return Builder {
		builder_ref: C.LLVMCreateBuilderInContext(ctx_ref)
	}
}

pub fn (mut b Builder) free() {
	C.LLVMDisposeBuilder(b.builder_ref)
}


pub struct Module {
	ctx_ref C.LLVMContextRef
	mod_ref C.LLVMModuleRef
mut:
	builder Builder
	funcs []Function
	built_in_funcs map[string]C.LLVMValueRef
	
	global_const map[GlobalVarRefType]C.LLVMValueRef
}

pub fn new_llvm_module(name string) Module {
	ctx_ref := C.LLVMContextCreate()
	builder := new_llvm_builder(ctx_ref)
	mod_ref := C.LLVMModuleCreateWithNameInContext(name.str, ctx_ref)
	mut mod := Module {
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
	m.builder.free()
	C.LLVMDisposeModule(m.mod_ref)
	C.LLVMContextDispose(m.ctx_ref)

}

pub fn (mut m Module) verify() ? {
	mut err := charptr(0)
	res := C.LLVMVerifyModule(m.mod_ref, .llvm_abort_process_action, &err)

	if res != 0 {
		unsafe{return error(err.vstring())}
	}
	return none
}

pub fn (mut m Module) add_global_string_literal_ptr(str_val string) C.LLVMValueRef {
	return C.LLVMBuildGlobalStringPtr(m.builder.builder_ref, charptr(str_val.str), charptr(no_name.str)) 
}

pub fn (m Module) print_to_file(path string) ? {
	mut err := charptr(0)
	res := C.LLVMPrintModuleToFile(m.mod_ref, path.str, &err)
	unsafe {
		if res != 0 {
			return error('Failed to print ll file $path, ${err.vstring()}')
		}
	}
	return none
}

pub fn (mut m Module) declare_function(func symbols.FunctionSymbol, body binding.BoundBlockStmt ) {
	m.funcs << new_llvm_func(m, func, body)
}


