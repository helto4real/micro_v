module core 

import lib.comp.symbols
import lib.comp.binding

pub struct Builder {
mut:
	builder_ref C.LLVMBuilderRef
}

pub fn new_llvm_builder() Builder {
	return Builder {
		builder_ref: C.LLVMCreateBuilder()
	}
}

pub fn (mut b Builder) free() {
	C.LLVMDisposeBuilder(b.builder_ref)
}

pub struct Module {
mut:
	mod_ref C.LLVMModuleRef
	builder Builder
	funcs []Function
	built_in_funcs map[string]C.LLVMValueRef
}

pub fn new_llvm_module(name string, builder Builder) Module {
	return Module {
		mod_ref: C.LLVMModuleCreateWithName(name.str)
		builder: builder

	}
}

pub fn (mut m Module) verify() ? {
	mut err := charptr(0)
	res := C.LLVMVerifyModule(m.mod_ref, .llvm_abort_process_action, &err)

	if res != 0 {
		unsafe{return error(err.vstring())}
	}
	return none
}

// pub fn (mut m Module) generate() {
// 	// start declaring the functions
// 	for func in m.funcs {
// 		func.llvm_func
// 	}
// 	// return_type := C.LLVMFunctionType(C.LLVMInt32Type(), param_types.data, 2, C.LLVMBool(0))
// 	// sum_name := 'sum'
// 	// sum := C.LLVMAddFunction(llvm_mod, sum_name.str, return_type)
// 	// entry_name := 'entry'
// 	// entry := C.LLVMAppendBasicBlock(sum, entry_name.str)

	
// }



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