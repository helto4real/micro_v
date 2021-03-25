module core

import lib.comp.symbols
import lib.comp.binding


pub struct Function {
	mod Module
	llvm_func_typ C.LLVMTypeRef
	llvm_func &C.LLVMValueRef
	func      symbols.FunctionSymbol
	body      binding.BoundBlockStmt
mut:
	llvm_entry_block &C.LLVMBasicBlockRef = 0
pub:
	ctx	  	  Context
}
fn new_llvm_func(mod Module, func symbols.FunctionSymbol, body binding.BoundBlockStmt) Function {
	llvm_params := get_params(func.params, mod)
	
	return_typ := if func.name == 'main' {
			C.LLVMInt32TypeInContext(mod.ctx_ref)
		} else {
			get_llvm_type_ref(func.typ, mod)
	}
	

	llvm_func_typ := C.LLVMFunctionType(return_typ, llvm_params.data,
				llvm_params.len, 0)

	func_name := func.name
	llvm_func := C.LLVMAddFunction(mod.mod_ref, func_name.str, llvm_func_typ)

	return Function{
		mod: mod
		llvm_func_typ: llvm_func_typ
		llvm_func: llvm_func
		llvm_entry_block: 0
		func: func
		body: body
	}
}

fn (mut f Function) generate_function_bodies() {
	entry_name := 'entry'
	entry := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.llvm_func, entry_name.str)
	f.llvm_entry_block = entry
	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, entry)
	mut ctx := new_context(f.mod, entry, f.llvm_func)
	// declare the inparameters 
	for i, param in f.func.params {
		param_ref := C.LLVMGetParam(f.llvm_func, i)
		ref_var := C.LLVMBuildAlloca(f.mod.builder.builder_ref, get_llvm_type_ref(param.typ, f.mod), no_name.str)

		C.LLVMBuildStore(f.mod.builder.builder_ref, param_ref, ref_var) 
		ctx.var_decl[param.id] = ref_var
	}
	
	// generate all blocks
	for stmt in f.body.bound_stmts {
		if stmt is binding.BoundLabelStmt {
			label_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.llvm_func, stmt.name.str)
			ctx.blocks[stmt.name] = label_block
		}
	}
	
	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, entry)
	for stmt in f.body.bound_stmts {
		ctx.emit_node(stmt)
	}
	if f.func.name == 'main' {
		return_code := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, f.mod), 0, false)
		C.LLVMBuildRet(f.mod.builder.builder_ref, return_code)
	} else {
		println(f.func.typ)
		if f.func.typ.kind == .void_symbol {
			C.LLVMBuildRetVoid(f.mod.builder.builder_ref)
		}  
	}
}

fn get_params(params []symbols.ParamSymbol, mod Module) []&C.LLVMTypeRef {
	mut res := []&C.LLVMTypeRef{cap: params.len}

	for param in params {
		res << get_llvm_type_ref(param.typ, mod)
	}

	return res
}
