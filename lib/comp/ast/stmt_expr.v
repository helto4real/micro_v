module ast

import lib.comp.util

pub struct ExprStmt {
pub:
	// general ast node
	kind        SyntaxKind = .expr_stmt
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	expr Expr
}

pub fn new_expr_stmt(expr Expr) ExprStmt {
	return ExprStmt{
		pos: expr.pos()
		child_nodes: [AstNode(expr)]
		expr: expr
	}
}
pub fn (e &ExprStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &ExprStmt) node_str() string {
	return typeof(ex).name
}
