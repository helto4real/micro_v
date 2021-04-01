module binding

import lib.comp.token
import lib.comp.symbols

pub fn block(stmts ...BoundStmt) BoundStmt {
	return new_bound_block_stmt(stmts)
}

pub fn goto_cond(expr BoundExpr, true_label string, false_label string) BoundStmt {
	return new_bound_cond_goto_stmt(expr, true_label, false_label)
}

pub fn goto_label(label string) BoundStmt {
	return new_bound_goto_stmt(label)
}

pub fn label(label string) BoundStmt {
	return new_bound_label_stmt(label)
}

pub fn var_decl(var symbols.VariableSymbol, expr BoundExpr, is_mut bool) BoundVarDeclStmt {
	// new_local_variable_symbol(name string, typ symbols.TypeSymbol, is_mut bool)
	// new_local_variable_symbol
	return new_var_decl_stmt(var, expr, is_mut) as BoundVarDeclStmt
}

pub fn var_decl_local(name string, typ symbols.TypeSymbol, expr BoundExpr, is_mut bool) BoundVarDeclStmt {
	var := symbols.new_local_variable_symbol(name, typ, is_mut)
	return new_var_decl_stmt(var, expr, is_mut) as BoundVarDeclStmt
}

// new_for_stmt(cond_expr BoundExpr, body_stmt BoundStmt, has_cond bool) BoundStmt
pub fn for_stmt(cond_expr BoundExpr, body_stmt BoundStmt) BoundStmt {
	return new_for_stmt(cond_expr, body_stmt, true)
}

pub fn variable_exp(var BoundVariableExpr) BoundVariableExpr {
	return new_bound_variable_with_names_expr(var.var, var.names, var.typ) as BoundVariableExpr
}

pub fn variable(var_decl BoundVarDeclStmt) BoundVariableExpr {
	return new_bound_variable_expr(var_decl.var, var_decl.var.typ) as BoundVariableExpr
}

pub fn binary(left BoundExpr, kind token.Kind, right BoundExpr) BoundExpr {
	// todo: fix error handling
	op := bind_binary_operator(kind, left.typ, right.typ) or { panic(err.msg) }

	return new_bound_binary_expr(left, op, right)
}

pub fn less_than(left BoundExpr, right BoundExpr) BoundExpr {
	return binary(left, .lt, right)
}

pub fn add(left BoundExpr, right BoundExpr) BoundExpr {
	return binary(left, .plus, right)
}

pub fn literal(val symbols.LitVal) BoundExpr {
	return new_bound_literal_expr(val)
}

pub fn increment(var_expr BoundVariableExpr) BoundStmt {
	incr := add(var_expr, literal(1))
	incr_assign := new_bound_assign_expr(var_expr.var, incr)
	return new_bound_expr_stmt(incr_assign)
}

pub fn @for(cond_expr BoundExpr, body_stmt BoundStmt, has_cond bool) BoundStmt {
	return new_for_stmt(cond_expr, body_stmt, has_cond )
}