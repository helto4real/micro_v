module emit
import lib.comp.gen.llvm.core
import lib.comp.binding
import lib.comp.symbols

fn (mut em EmitModule) declare_fn(func &symbols.FunctionSymbol, stmts binding.BoundBlockStmt) &FunctionDecl {
	func_name :=  if !func.is_c_decl { func.name } else { func.name[2..] }

	mut return_typ := if func_name == 'main' || (em.is_test && func_name.starts_with('test_')) {
		em.ctx.int32_type()
	} else {
		em.get_type_from_type_symb(func.typ)
	}
	if func.typ.is_ref {
		return_typ = return_typ.to_pointer_type(0)
	}
	
	mut fn_decl := new_fn_decl_with_symbol(func_name, return_typ, func, stmts, em)
	mut params, is_variadic := fn_decl.get_params_types(func.params)

	if !func.receiver.is_empty {
		receiver_typ := em.get_type_from_type_symb(func.receiver.typ)
		// it is a recieiver function `fn (x Type) foo(){}`
		if !func.receiver.is_ref {
			params.prepend(receiver_typ)
		} else {
			params.prepend(receiver_typ.to_pointer_type(0))
		}
	}
	if is_variadic {fn_decl.set_variadic()}
	
	fn_decl.params << params

	fn_decl.emit()
	em.funcs << fn_decl

	return fn_decl
}

[heap]
pub struct FunctionDecl {
mut:
	em &EmitModule
	bld core.Builder
	ctx core.Context
	func &symbols.FunctionSymbol = 0
	body binding.BoundBlockStmt
	
	typ core.Type
	val core.Value
	last_val core.Value
	current_block core.BasicBlock
	
	blocks map[string]core.BasicBlock

pub:
	name string
	return_typ core.Type
pub mut:
	is_variadic bool
	params []core.Type
}

pub fn new_fn_decl(name string, return_typ core.Type, em &EmitModule) &FunctionDecl {
	return &FunctionDecl {
		name: name
		return_typ: return_typ
		em: em
		bld: em.bld
		ctx: em.ctx
	}
}

pub fn new_fn_decl_with_symbol(name string, return_typ core.Type, func &symbols.FunctionSymbol, body &binding.BoundBlockStmt, em &EmitModule) &FunctionDecl {
	return &FunctionDecl {
		name: name
		return_typ: return_typ
		em: em
		func: func
		body: body
		bld: em.bld
		ctx: em.ctx
	}
}

pub fn (mut fd FunctionDecl) emit() core.Value {
	fd.typ = core.new_function_type(fd.return_typ, fd.params, fd.is_variadic)
	fd.val = fd.typ.add_function(fd.name, fd.em.mod)
	return fd.val
}

pub fn (mut fd FunctionDecl) emit_type() core.Type {
	fd.typ = core.new_function_type(fd.return_typ, fd.params, fd.is_variadic)
	return fd.typ
}

pub fn (mut fd FunctionDecl) emit_body() {
	fd.emit_blocks_and_parameters()

	if fd.func.name == 'main' {
		fd.emit_main_fn_body_error_handling()
	}

	main_block := fd.current_block
	// generate all blocks from labels
	for stmt in fd.body.stmts {
		if stmt is binding.BoundLabelStmt {
			label_block := fd.em.ctx.new_basic_block(fd.val, stmt.name)
			fd.blocks[stmt.name] = label_block
			label_block.move_after(fd.current_block)
			fd.current_block = label_block
		}
	}

	// Generate the statements at entry
	fd.bld.position_at_end(main_block)

	for stmt in fd.body.stmts {
		fd.emit_stmt(stmt)
	}

	if fd.func.name == 'main' || (fd.em.is_test && fd.func.name.starts_with('test_')) {
		// Normal return code exit
		exit_code := fd.em.ctx.c_i32(0, false)
		fd.bld.create_ret(exit_code)
	} else {
		if fd.func.typ.kind == .void_symbol {
			fd.bld.create_ret_void()
		}
	}

}

pub fn (mut fd FunctionDecl) set_variadic() {
	fd.is_variadic = true
}

fn (mut fd FunctionDecl) get_params_types(params []symbols.ParamSymbol) ([]core.Type, bool) {
	mut param_types := []core.Type{cap: params.len}
	mut is_variadic := false
	for param in params {
		if !param.is_variadic {
			if !param.is_ref {
				param_types << fd.em.get_type_from_type_symb(param.typ)
			} else {
				typ := fd.em.get_type_from_type_symb(param.typ)
				param_types << typ.to_pointer_type(0)
			}
		} else {
			is_variadic = true
		}
	}

	return param_types, is_variadic
}
pub fn (mut fd FunctionDecl) emit_blocks_and_parameters() {
	fd.current_block = fd.em.ctx.new_basic_block(fd.val, 'entry')

	fd.bld.position_at_end(fd.current_block)
	// Generate the statements at entry
	mut pi := 0
	if !fd.func.receiver.is_empty {
		pi = 1 // the rest of the parameters are now at index 1
		param_val := fd.val.param(0)
		receiver_typ := if fd.func.receiver.is_ref {
			fd.em.get_type_from_type_symb(fd.func.receiver.typ).to_pointer_type(0)
		} else {
			fd.em.get_type_from_type_symb(fd.func.receiver.typ)
		}

		if fd.func.receiver.is_ref || fd.func.receiver.is_mut {
			fd.em.var_decl[fd.func.receiver.id] = param_val
		} else {
			fd.em.var_decl[fd.func.receiver.id] = fd.bld.alloca_and_store(receiver_typ, param_val, '')
		}
	}

	// declare the inparameters
	for i, param in fd.func.params {
		param_val := fd.val.param(i + pi)
		param_typ := if param.is_ref {
			fd.em.get_type_from_type_symb(param.typ).to_pointer_type(0)
		} else {
			fd.em.get_type_from_type_symb(param.typ)
		}
		if param.is_ref || param.is_mut {
			fd.em.var_decl[param.id] = param_val
		} else {
			fd.em.var_decl[param.id] = fd.bld.alloca_and_store(param_typ, param_val, '')
		}
	}
}

fn (mut fd FunctionDecl) emit_main_fn_body_error_handling() {
	// entry:
	//   res = setjmp
	//   branch if res error: else continue
	// continue:
	// 	 <body>
	//   ret 0
	// error_exit:
	//   ret 1
	continue_block := fd.em.ctx.new_basic_block(fd.val,'continue')

	continue_block.move_after(fd.current_block)

	error_exit_block := fd.em.ctx.new_basic_block(fd.val,'error_exit')

	error_exit_block.move_after(continue_block)

	buff_arg := fd.em.global_const[GlobalVarRefType.jmp_buff]
	res := fd.emit_call_builtin('C.setjmp', buff_arg)
	
	cmp_val := fd.bld.create_icmp(.int_eq, res, fd.em.ctx.c_i64(0, false)) 

	fd.bld.create_cond_br(cmp_val, continue_block, error_exit_block)


	fd.bld.position_at_end(error_exit_block)


	error_code := fd.ctx.c_i32(1, false)
	fd.bld.create_ret(error_code)

	fd.current_block = continue_block
	fd.bld.position_at_end(continue_block)
}