module lowering

import lib.comp.binding

fn (mut l Lowerer) rewrite_block_stmt(stmt binding.BoundBlockStmt) binding.BoundStmt {
	mut ret_block_stmt := []binding.BoundStmt{}
	for old_stmt in stmt.bound_stmts {
		new_stmt := l.rewrite_stmt(old_stmt)
		// for j := 0; j < i; j++ {
		// 	ret_block_stmt << stmt.bound_stmts[j]
		// }
		ret_block_stmt << new_stmt
	}
	if ret_block_stmt.len == 0 {
		return stmt
	}
	return binding.new_bound_block_stmt(ret_block_stmt)
}
fn (mut l Lowerer) rewrite_expr_stmt(stmt binding.BoundExprStmt) binding.BoundStmt {
	new_expr := l.rewrite_expr(stmt.bound_expr)
	return binding.new_bound_expr_stmt(new_expr)
}
fn (mut l Lowerer) rewrite_for_range_stmt(stmt binding.BoundForRangeStmt) binding.BoundStmt {
	return stmt
}
fn (mut l Lowerer) rewrite_for_stmt(stmt binding.BoundForStmt) binding.BoundStmt {
	return stmt
}
fn (mut l Lowerer) rewrite_var_decl_stmt(stmt binding.BoundVarDeclStmt) binding.BoundStmt {
	new_expr := l.rewrite_expr(stmt.expr)
	return binding.new_var_decl_stmt(stmt.var, new_expr, stmt.is_mut)
}
fn (mut l Lowerer) rewrite_label_stmt(stmt binding.BoundLabelStmt) binding.BoundStmt {
	return stmt
}
fn (mut l Lowerer) rewrite_goto_stmt(stmt binding.BoundGotoStmt) binding.BoundStmt {
	return stmt
}
fn (mut l Lowerer) rewrite_cond_goto_stmt(stmt binding.BoundCondGotoStmt) binding.BoundStmt {
	cond := l.rewrite_expr(stmt.cond)
	return binding.new_bound_cond_goto_stmt(stmt.label, cond, stmt.jump_if_true)
}

pub fn (mut l Lowerer) rewrite_expr(expr binding.BoundExpr) binding.BoundExpr {
	match expr {
		binding.BoundLiteralExpr { return l.rewrite_literal_expr(expr) }
		binding.BoundUnaryExpr { return l.rewrite_unary_expr(expr) }
		binding.BoundBinaryExpr { return l.rewrite_binary_expr(expr) }
		binding.BoundAssignExpr { return l.rewrite_assign_expr(expr) }
		binding.BoundIfExpr { return l.rewrite_if_expr(expr) }
		binding.BoundRangeExpr { return l.rewrite_range_expr(expr) }
		binding.BoundVariableExpr { return l.rewrite_variable_expr(expr) }
		// else { panic('unexpected bound expression $expr') }
	}
}

pub fn (mut l Lowerer) rewrite_variable_expr(expr binding.BoundVariableExpr) binding.BoundExpr {
	return expr
}

pub fn (mut l Lowerer) rewrite_literal_expr(expr binding.BoundLiteralExpr) binding.BoundExpr {
	return expr
}
pub fn (mut l Lowerer) rewrite_unary_expr(expr binding.BoundUnaryExpr) binding.BoundExpr {
	operand := l.rewrite_expr(expr.operand)
	return binding.new_bound_unary_expr(expr.op , operand ) 
}
pub fn (mut l Lowerer) rewrite_binary_expr(expr binding.BoundBinaryExpr) binding.BoundExpr {
	left := l.rewrite_expr(expr.left)
	right := l.rewrite_expr(expr.right)
	return binding.new_bound_binary_expr(left, expr.op, right)
}
pub fn (mut l Lowerer) rewrite_assign_expr(expr binding.BoundAssignExpr) binding.BoundExpr {
	rewritten_expr := l.rewrite_expr(expr.expr)
	return binding.new_bound_assign_expr(expr.var, rewritten_expr)
}

pub fn (mut l Lowerer) rewrite_range_expr(expr binding.BoundRangeExpr) binding.BoundExpr {
	return expr
}
