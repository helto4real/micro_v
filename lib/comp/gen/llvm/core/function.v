module core

import lib.comp.symbols
import lib.comp.binding

[heap]
pub struct Function {
	mod          &Module
	name         string
	func_typ_ref &C.LLVMTypeRef  = 0
	func_ref     &C.LLVMValueRef = 0
	func         symbols.FunctionSymbol
	body         binding.BoundBlockStmt
mut:
	var_decl         map[string]&C.LLVMValueRef
	llvm_entry_block &C.LLVMBasicBlockRef = 0
}

fn new_llvm_func(mod &Module, func symbols.FunctionSymbol, body binding.BoundBlockStmt) &Function {
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

	return_typ := if func_name == 'main' || (mod.is_test && func_name.starts_with('test_')) {
		C.LLVMInt32TypeInContext(mod.ctx_ref)
	} else {
		mod.get_llvm_type(func.typ)
	}
	variadic_val := if is_variadic { 1 } else { 0 }

	func_typ_ref := C.LLVMFunctionType(return_typ, llvm_params.data, llvm_params.len,
		variadic_val)

	func_ref := C.LLVMAddFunction(mod.mod_ref, func_name.str, func_typ_ref)

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

	// Generate the statements at entry
	C.LLVMPositionBuilderAtEnd(mod.builder.builder_ref, entry)
	mut pi := 0
	if !f.func.receiver.is_empty {
		pi = 1 // the rest of the parameters are now at index 1

		param_ref := C.LLVMGetParam(f.func_ref, 0)
		typ := if f.func.receiver.is_ref {
			C.LLVMPointerType(f.mod.get_llvm_type(f.func.receiver.typ), 0)
		} else {
			f.mod.get_llvm_type(f.func.receiver.typ)
		}

		if f.func.receiver.is_ref || f.func.receiver.is_mut {
			f.var_decl[f.func.receiver.id] = param_ref
		} else {
			ref_var := C.LLVMBuildAlloca(f.mod.builder.builder_ref, typ, no_name.str)
			C.LLVMBuildStore(f.mod.builder.builder_ref, param_ref, ref_var)
			f.var_decl[f.func.receiver.id] = ref_var
		}
	}

	// declare the inparameters
	for i, param in f.func.params {
		param_ref := C.LLVMGetParam(f.func_ref, i + pi)
		typ := if param.is_ref {
			C.LLVMPointerType(f.mod.get_llvm_type(param.typ), 0)
		} else {
			f.mod.get_llvm_type(param.typ)
		}
		if param.is_ref || param.is_mut {
			f.var_decl[param.id] = param_ref
		} else {
			ref_var := C.LLVMBuildAlloca(f.mod.builder.builder_ref, typ, no_name.str)
			C.LLVMBuildStore(mod.builder.builder_ref, param_ref, ref_var)
			f.var_decl[param.id] = ref_var
		}
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
		cmp_ref := C.LLVMBuildICmp(f.mod.builder.builder_ref, .int_eq, res, C.LLVMConstInt(f.mod.get_llvm_type(symbols.i64_symbol), i64(0), false), no_name.str)
		C.LLVMBuildCondBr(emitter.mod.builder.builder_ref, cmp_ref, continue_block, error_exit_block)

		C.LLVMPositionBuilderAtEnd(f.mod.builder.builder_ref, error_exit_block)
		// fn_ref := f.mod.built_in_funcs['exit'] or { panic('built in function exit not found') }

		error_code := C.LLVMConstInt(f.mod.get_llvm_type(symbols.int_symbol), 1,
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
		return_code := C.LLVMConstInt(f.mod.get_llvm_type(symbols.int_symbol), 0,
			0)
		C.LLVMBuildRet(f.mod.builder.builder_ref, return_code)
	} else {
		if f.func.typ.kind == .void_symbol {
			C.LLVMBuildRetVoid(f.mod.builder.builder_ref)
		}
	}
}

fn get_params(params []symbols.ParamSymbol, mod Module) ([]&C.LLVMTypeRef, bool) {
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
