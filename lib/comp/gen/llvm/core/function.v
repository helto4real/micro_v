module core

import lib.comp.symbols
import lib.comp.binding

pub struct Function {
	mod          Module
	func_typ_ref &C.LLVMTypeRef
	func_ref     &C.LLVMValueRef
	func         symbols.FunctionSymbol
	body         binding.BoundBlockStmt
mut:
	llvm_entry_block &C.LLVMBasicBlockRef = 0
pub:
	ctx Emitter
}

fn new_llvm_func(mod Module, func symbols.FunctionSymbol, body binding.BoundBlockStmt) Function {
	llvm_params := get_params(func.params, mod)

	return_typ := if func.name == 'main' || (mod.is_test && func.name.starts_with('test_')) {
		C.LLVMInt32TypeInContext(mod.ctx_ref)
	} else {
		get_llvm_type_ref(func.typ, mod)
	}

	func_typ_ref := C.LLVMFunctionType(return_typ, llvm_params.data, llvm_params.len,
		0)

	func_name := func.name
	func_ref := C.LLVMAddFunction(mod.mod_ref, func_name.str, func_typ_ref)

	return Function{
		mod: mod
		func_typ_ref: func_typ_ref
		func_ref: func_ref
		llvm_entry_block: 0
		func: func
		body: body
	}
}

fn (mut f Function) generate_function_bodies() {
	entry_name := 'entry'
	entry := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref, entry_name.str)
	f.llvm_entry_block = entry
	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, entry)
	mut ctx := new_emitter(f.mod, entry, f.func_ref)
	// declare the inparameters 
	for i, param in f.func.params {
		param_ref := C.LLVMGetParam(f.func_ref, i)
		ref_var := C.LLVMBuildAlloca(f.mod.builder.builder_ref, get_llvm_type_ref(param.typ,
			f.mod), no_name.str)

		C.LLVMBuildStore(f.mod.builder.builder_ref, param_ref, ref_var)
		ctx.var_decl[param.id] = ref_var
	}

	mut main_block := entry

	if f.func.name == 'main' {
		// entry: 
		//   res = setjmp 
		//   branch if res error: else continue
		// continue:
		// 	 <body>
		//   ret 0
		// error_exit:
		//   ret 1 
		continue_str := 'continue'
		continue_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref, continue_str.str)

		C.LLVMMoveBasicBlockAfter(continue_block, entry)

		error_exit_str := 'error_exit'
		error_exit_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref,
			error_exit_str.str)

		C.LLVMMoveBasicBlockAfter(error_exit_block, continue_block)

		mut cb := ctx.new_builtin_call('setjmp')
		cb.add_param(f.mod.jmp_buff)
		res := cb.emit()
		cmp_ref := C.LLVMBuildICmp(f.mod.builder.builder_ref, .int_eq, res, C.LLVMConstInt(get_llvm_type_ref(symbols.i64_symbol,
			f.mod), i64(0), false), no_name.str)
		C.LLVMBuildCondBr(ctx.mod.builder.builder_ref, cmp_ref, continue_block, error_exit_block)

		C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, error_exit_block)
		// fn_ref := f.mod.built_in_funcs['exit'] or { panic('built in function exit not found') }

		error_code := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, f.mod), 1,
			false)
		// mut params := []&C.LLVMValueRef{cap: 1}
		// params << error_code
		// C.LLVMBuildCall(f.mod.builder.builder_ref, fn_ref, params.data, 1, no_name.str)
		C.LLVMBuildRet(f.mod.builder.builder_ref, error_code)

		main_block = continue_block
		// C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, continue_block)
	}
	mut current_block := main_block
	// generate all blocks
	for stmt in f.body.stmts {
		if stmt is binding.BoundLabelStmt {
			label_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref,
				stmt.name.str)
			ctx.blocks[stmt.name] = label_block
			C.LLVMMoveBasicBlockAfter(label_block, current_block)
			current_block = label_block
		}
	}

	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, main_block)
	for stmt in f.body.stmts {
		ctx.emit_stmt(stmt)
	}
	if f.func.name == 'main' || (f.mod.is_test && f.func.name.starts_with('test_')) {
		// C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, continue_block)
		// Normal return code exit
		return_code := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, f.mod), 0,
			0)
		C.LLVMBuildRet(f.mod.builder.builder_ref, return_code)
	} else {
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
