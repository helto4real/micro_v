module core


pub fn (mut m Module) add_standard_funcs() {
	//Argument type
	mut puts_function_args_type := []C.LLVMTypeRef{}
	puts_function_args_type << C.LLVMPointerType(C.LLVMInt8Type(), 0)
	// puts function
	puts_function_type := C.LLVMFunctionType(C.LLVMInt32Type(), puts_function_args_type.data, 1, false)
	// Add puts
	func_typ := C.LLVMAddFunction(m.mod_ref, "puts", puts_function_type)
	m.built_in_funcs['println'] = func_typ
}