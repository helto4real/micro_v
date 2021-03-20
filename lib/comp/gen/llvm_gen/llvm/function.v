module llvm

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
	ctx := new_context(mod)
	llvm_params := get_params(func.params)
	
	llvm_func_typ := C.LLVMFunctionType(C.LLVMInt32Type(), llvm_params.data,
				llvm_params.len, 0)

	func_name := func.name
	llvm_func := C.LLVMAddFunction(mod.mod_ref, func_name.str, llvm_func_typ)
	entry_name := 'entry'
	entry := C.LLVMAppendBasicBlock(llvm_func, entry_name.str)
	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(mod.builder.builder_ref, entry)
	for stmt in body.bound_stmts {
		emit_nodes( ctx, stmt)
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

[inline]
fn get_llvm_type_ref(typ symbols.TypeSymbol) C.LLVMTypeRef {
	match typ.name {
		'int' {
			return C.LLVMInt32Type()
		}
		else {return C.LLVMInt32Type()}
		// 'string' {
		// 	res << C.
		// }
	}
}