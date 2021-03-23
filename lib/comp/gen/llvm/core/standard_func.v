module core

pub fn (mut m Module) add_standard_funcs() {
	m.add_puts()
	m.add_printf()
}

fn (mut m Module) add_puts() {
		//Argument type
	mut puts_function_args_type := []&C.LLVMTypeRef{}
	puts_function_args_type << C.LLVMPointerType(C.LLVMInt8TypeInContext(m.ctx_ref), 0)
	// puts function
	puts_function_type := C.LLVMFunctionType(C.LLVMInt32TypeInContext(m.ctx_ref), puts_function_args_type.data, 1, false)
	// Add puts
	func_typ := C.LLVMAddFunction(m.mod_ref, "puts", puts_function_type)
	m.built_in_funcs['puts'] = func_typ
}

fn (mut m Module) add_printf() {
		//Argument type
	mut puts_function_args_type := []&C.LLVMTypeRef{}
	// Add the char* format
	puts_function_args_type << C.LLVMPointerType(C.LLVMInt8TypeInContext(m.ctx_ref), 0)
	// puts function
	puts_function_type := C.LLVMFunctionType(C.LLVMInt32TypeInContext(m.ctx_ref), puts_function_args_type.data, 1, true)
	// Add puts
	func_typ := C.LLVMAddFunction(m.mod_ref, "printf", puts_function_type)
	m.built_in_funcs['printf'] = func_typ
}