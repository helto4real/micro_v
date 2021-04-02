module core

import lib.comp.symbols

pub fn (mut m Module) add_standard_funcs() {
	m.add_longjmp_setjmp()
}

fn (mut m Module) add_longjmp_setjmp() {
	// declare the jmp buffer
	// TODO: size depending on target
	jumb_buff_global_name := 'jmp_buf'
	jmp_buf_typ_ref := m.types['JumpBuffer']

	mut value_refs := [C.LLVMConstInt(get_llvm_type_ref(symbols.i64_symbol, m), i64(0),
		false)]

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
		2, false)
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
		1, false)
	// Add puts
	func_typ_setjmp := C.LLVMAddFunction(m.mod_ref, 'setjmp', setjmp_function_type)
	m.built_in_funcs['setjmp'] = func_typ_setjmp
}

pub fn (mut m Module) get_standard_struct_types() []symbols.StructTypeSymbol {
	// declare the jumb_buf
	// Todo: size depending on target arch
	mut res := []symbols.StructTypeSymbol{}
	mut jmp_buf_symbol := symbols.new_struct_symbol('JumpBuffer')
	jmp_buf_symbol.members << symbols.new_struct_type_member('', symbols.i64_symbol)
	res << jmp_buf_symbol

	return res
}
