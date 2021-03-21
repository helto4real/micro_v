module core

import lib.comp.symbols
import lib.comp.binding


pub struct Function {
	llvm_func_typ C.LLVMTypeRef
	llvm_func C.LLVMValueRef
	llvm_entry_block C.LLVMBasicBlockRef
	func      symbols.FunctionSymbol
	body      binding.BoundBlockStmt
pub:
	ctx	  	  Context
}
fn new_llvm_func(mod Module, func symbols.FunctionSymbol, body binding.BoundBlockStmt) Function {
	llvm_params := get_params(func.params)
	
	return_typ := if func.name == 'main' {
			C.LLVMInt32Type()
		} else {
			get_llvm_type_ref(func.typ)
	}

	llvm_func_typ := C.LLVMFunctionType(return_typ, llvm_params.data,
				llvm_params.len, 0)

	func_name := func.name
	llvm_func := C.LLVMAddFunction(mod.mod_ref, func_name.str, llvm_func_typ)

	if body.bound_stmts.len == 0 {
		return Function{
			llvm_func_typ: llvm_func_typ
			llvm_func: llvm_func
			func: func
			body: body
		}
	}
	entry_name := 'entry'
	entry := C.LLVMAppendBasicBlock(llvm_func, entry_name.str)
	mut ctx := new_context(mod, entry)
	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(mod.builder.builder_ref, entry)
	for stmt in body.bound_stmts {
		ctx.emit_node(stmt)
	}
	if func.name == 'main' {
		return_code := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol), 0, false)
		C.LLVMBuildRet(mod.builder.builder_ref, return_code)
	}
	return Function{
		ctx: ctx
		llvm_func_typ: llvm_func_typ
		llvm_func: llvm_func
		llvm_entry_block: entry
		func: func
		body: body
	}
}


fn get_params(params []symbols.ParamSymbol) []C.LLVMTypeRef {
	mut res := []C.LLVMTypeRef{cap: params.len}

	for param in params {
		res << get_llvm_type_ref(param.typ)
	}

	return res
}
