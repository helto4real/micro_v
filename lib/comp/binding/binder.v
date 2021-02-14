module binding

import lib.comp.ast
import lib.comp.util

pub struct Binder {
pub mut:
	log util.Diagnostics // errors when parsing
}

pub fn bind_syntaxt_tree(expr ast.Expression) BoundExpr {
	mut bind := new_binder()
	return bind.bind_expr(expr)
}

pub fn new_binder() Binder {
	return Binder{}
}

pub fn (mut b Binder) bind_expr(expr ast.Expression) BoundExpr {
	match expr {
		ast.LiteralExpr { return b.bind_literal_expr(expr) }
		ast.UnaryExpr { return b.bind_unary_expr(expr) }
		ast.BinaryExpr { return b.bind_binary_expr(expr) }
		ast.ParaExpr { return b.bind_expr(expr.expr) }
		else { panic('unexpected bound expression $expr') }
	}
}

fn (mut b Binder) bind_literal_expr(syntax ast.LiteralExpr) BoundExpr {
	val := syntax.val
	return new_bound_literal_expr(val)
}

enum BoundNodeKind {
	unary_expression
	binary_expr
	literal_expression
}
