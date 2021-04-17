module core

import lib.comp.symbols
import lib.comp.binding

[heap]
pub struct Function {
	mod          &AModule
	name         string
	func_typ_ref &C.LLVMTypeRef  = 0
	func_ref     &C.LLVMValueRef = 0
	func         symbols.FunctionSymbol
	body         binding.BoundBlockStmt
mut:
	var_decl         map[string]&C.LLVMValueRef
	llvm_entry_block &C.LLVMBasicBlockRef = 0
}

fn new_llvm_func(mod &AModule, func symbols.FunctionSymbol, body binding.BoundBlockStmt) &Function {
	func_name := if !func.is_c_decl { func.name } else { func.name[2..] }
	mut llvm_params, is_variadic := get_params(func.params, mod)

	if !func.receiver.is_empty {
		typ_ref := mod.get_llvm_type(func.receiver.typ)
		// it is a recieiver function `fn (x Type) foo(){}`
		if !func.receiver.is_ref {
			llvm_params.prepend(typ_ref)
		} else {
			llvm_params.prepend(C.LLVMPointerType(typ_ref, 0))
		}
	}

	mut return_typ := if func_name == 'main' || (mod.is_test && func_name.starts_with('test_')) {
		C.LLVMInt32TypeInContext(mod.ctx_ref)
	} else {
		mod.get_llvm_type(func.typ)
	}
	if func.typ.is_ref {
		return_typ = C.LLVMPointerType(return_typ, 0)
	}

	func_typ_ref := C.LLVMFunctionType(return_typ, llvm_params.data, llvm_params.len,
		bool_to_llvm_bool(is_variadic))
	//
	unique_fn_name := if !func.is_c_decl && func_name != 'main' {
		func.unique_fn_name()
	} else {
		func_name
	}
	// unique_name := unique_fn_name.replace('.', '_')
	func_ref := C.LLVMAddFunction(mod.mod_ref, unique_fn_name.str, func_typ_ref)

	entry_name := 'entry'
	mut entry := &C.LLVMBasicBlockRef(0)

	if !func.is_c_decl {
		entry = C.LLVMAppendBasicBlockInContext(mod.ctx_ref, func_ref, entry_name.str)
	}

	mut f := &Function{
		mod: mod
		func_typ_ref: func_typ_ref
		func_ref: func_ref
		llvm_entry_block: entry
		name: func_name
		func: func
		body: body
	}

	if func.is_c_decl {
		return f
	}



	return f
}

fn (f Function) str() string {
	return 'func: $f.name, $f.func.id'
}

fn (mut f Function) generate_function_bodies() {
	mut emitter := new_emitter(f.mod, f.llvm_entry_block, f)
	mut main_block := f.llvm_entry_block
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, main_block)
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

		C.LLVMMoveBasicBlockAfter(continue_block, f.llvm_entry_block)

		error_exit_str := 'error_exit'
		error_exit_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref,
			error_exit_str.str)

		C.LLVMMoveBasicBlockAfter(error_exit_block, continue_block)

		mut cb := emitter.new_builtin_call('setjmp')
		cb.add_param(f.mod.jmp_buff)
		res := cb.emit()
		cmp_ref := C.LLVMBuildICmp(f.mod.builder.builder_ref, .int_eq, res, C.LLVMConstInt(f.mod.get_llvm_type(symbols.i64_symbol),
			i64(0), bool_to_llvm_bool(false)), no_name.str)
		C.LLVMBuildCondBr(emitter.mod.builder.builder_ref, cmp_ref, continue_block, error_exit_block)

		C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, error_exit_block)

		error_code := C.LLVMConstInt(f.mod.get_llvm_type(symbols.int_symbol), 1, bool_to_llvm_bool(false))
		C.LLVMBuildRet(f.mod.builder.builder_ref, error_code)

		main_block = continue_block
	}
	mut current_block := main_block
	// generate all blocks
	for stmt in f.body.stmts {
		if stmt is binding.BoundLabelStmt {
			label_block := C.LLVMAppendBasicBlockInContext(f.mod.ctx_ref, f.func_ref,
				stmt.name.str)
			emitter.blocks[stmt.name] = label_block
			C.LLVMMoveBasicBlockAfter(label_block, current_block)
			current_block = label_block
		}
	}

	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, main_block)
	for stmt in f.body.stmts {
		emitter.emit_stmt(stmt)
	}
	if f.func.name == 'main' || (f.mod.is_test && f.func.name.starts_with('test_')) {
		// C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, continue_block)
		// Normal return code exit
		return_code := C.LLVMConstInt(f.mod.get_llvm_type(symbols.int_symbol), 0, bool_to_llvm_bool(false))
		C.LLVMBuildRet(f.mod.builder.builder_ref, return_code)
	} else {
		if f.func.typ.kind == .void_symbol {
			C.LLVMBuildRetVoid(f.mod.builder.builder_ref)
		}
	}
}

fn get_params(params []symbols.ParamSymbol, mod AModule) ([]&C.LLVMTypeRef, bool) {
	mut res := []&C.LLVMTypeRef{cap: params.len}
	mut is_variadic := false
	for param in params {
		if !param.is_variadic {
			if !param.is_ref {
				res << mod.get_llvm_type(param.typ)
			} else {
				res << C.LLVMPointerType(mod.get_llvm_type(param.typ), 0)
			}
		} else {
			is_variadic = true
		}
	}

	return res, is_variadic
}
