module lowering

import lib.comp.binding
import lib.comp.types
import lib.comp.token
import lib.comp.symbols

fn block(stmts ...binding.BoundStmt) binding.BoundStmt {
	return binding.new_bound_block_stmt(stmts)
}

fn goto_false(label string, expr binding.BoundExpr) binding.BoundStmt {
	return binding.new_bound_cond_goto_stmt(label, expr, false)
}

fn goto_true(label string, expr binding.BoundExpr) binding.BoundStmt {
	return binding.new_bound_cond_goto_stmt(label, expr, true)
}

fn goto_label(label string) binding.BoundStmt {
	return binding.new_bound_goto_stmt(label)
}

fn label(label string) binding.BoundStmt {
	return binding.new_bound_label_stmt(label)
}

fn var_decl(var symbols.VariableSymbol, expr binding.BoundExpr, is_mut bool) binding.BoundVarDeclStmt {
	// new_local_variable_symbol(name string, typ symbols.TypeSymbol, is_mut bool)
	// new_local_variable_symbol
	return binding.new_var_decl_stmt(var, expr, is_mut) as binding.BoundVarDeclStmt
}

fn var_decl_local(name string, typ symbols.TypeSymbol, expr binding.BoundExpr, is_mut bool) binding.BoundVarDeclStmt {
	var := symbols.new_local_variable_symbol(name, typ, is_mut)
	return binding.new_var_decl_stmt(var, expr, is_mut) as binding.BoundVarDeclStmt
}

// new_for_stmt(cond_expr BoundExpr, body_stmt BoundStmt, has_cond bool) BoundStmt
fn for_stmt(cond_expr binding.BoundExpr, body_stmt binding.BoundStmt) binding.BoundStmt {
	return binding.new_for_stmt(cond_expr, body_stmt, true)
}

fn variable_exp(var binding.BoundVariableExpr) binding.BoundVariableExpr {
	return binding.new_bound_variable_expr(var.var) as binding.BoundVariableExpr
}

fn variable(var_decl binding.BoundVarDeclStmt) binding.BoundVariableExpr {
	return binding.new_bound_variable_expr(var_decl.var) as binding.BoundVariableExpr
}

fn binary(left binding.BoundExpr, kind token.Kind, right binding.BoundExpr) binding.BoundExpr {
	// todo: fix error handling
	op := binding.bind_binary_operator(kind, left.typ(), right.typ()) or { panic(err.msg) }

	return binding.new_bound_binary_expr(left, op, right)
}

fn less_than(left binding.BoundExpr, right binding.BoundExpr) binding.BoundExpr {
	return binary(left, .lt, right)
}

fn add(left binding.BoundExpr, right binding.BoundExpr) binding.BoundExpr {
	return binary(left, .plus, right)
}

fn literal(val types.LitVal) binding.BoundExpr {
	return binding.new_bound_literal_expr(val)
}

fn increment(var_expr binding.BoundVariableExpr) binding.BoundStmt {
	incr := add(var_expr, literal(1))
	incr_assign := binding.new_bound_assign_expr(var_expr.var, incr)
	return binding.new_bound_expr_stmt(incr_assign)
}
