module emit

import lib.comp.gen.llvm.core
import lib.comp.symbols
import lib.comp.binding

fn (mut fd FunctionDecl) emit_call_builtin(name string, args ...core.Value) core.Value {
	func_name := if !name.starts_with('C.') { name } else { name[2..] }
	res := fd.em.funcs.filter(it.name == func_name)
	if res.len == 0 {
		panic('builtin function $name not declared in $fd.em.built_in_funcs')
	}
	func := res[0]
	return fd.bld.create_call2(func.typ, func.val, args)
}

fn (mut fd FunctionDecl) emit_variable_value(var &symbols.VariableSymbol, expr &binding.BoundExpr, val core.Value) core.Value {
	if var.is_ref && val.is_constant() { 
		var_typ := fd.em.get_type_from_type_symb(var.typ)
		return fd.bld.alloca_and_store(var_typ, val, '')
	}
	mut expr_is_ref := expr.typ.is_ref
	if !var.is_ref {
		if expr is binding.BoundVariableExpr {
			expr_is_ref = expr_is_ref || expr.var.is_ref
		} 
		if expr_is_ref {
			var_typ := fd.em.get_type_from_type_symb(var.typ)
			return fd.bld.create_load2(var_typ, val)
		}
	}
	return val
}

fn (mut fd FunctionDecl) emit_call_fn(call_expr binding.BoundCallExpr) core.Value {
	func_res := fd.em.funcs.filter(it.func > 0 && it.func.id == call_expr.func.id)
	if func_res.len != 1 {
		panic('unexpected, function $call_expr.func.name not declared. ($fd.em.funcs.len)')
	}
	func_decl := func_res[0]
	args_len := if func_decl.func.receiver.is_empty {
		call_expr.params.len
	} else {
		call_expr.params.len + 1
	}
	mut args := []core.Value{cap: args_len}
	if !func_decl.func.receiver.is_empty {
		rec_var := fd.em.var_decl[call_expr.receiver.id] or {
			panic('receiver: $call_expr.receiver ($call_expr.receiver.id) is not declared $fd.em.var_decl, $fd.em.var_decl.len')
		}
		if !func_decl.func.receiver.is_ref {
			args << fd.dereference(rec_var)
		} else {
			args << rec_var // c.handle_box_unbox_variable(func.func.receiver, rec_var)
		}
	}
	for i, param_expr in call_expr.params {
		expr_val := fd.emit_expr(param_expr)
		decl_param := func_decl.func.params[i]
		args << fd.emit_variable_value(&decl_param, &param_expr, expr_val)
	}

	if call_expr.typ.kind == symbols.TypeSymbolKind.void_symbol {
		// no return value
		fd.bld.create_call2(func_decl.typ, func_decl.val, args)
		return core.Value{
			c: 0
		}
	}
	return fd.bld.create_call2(func_decl.typ, func_decl.val, args)
}
