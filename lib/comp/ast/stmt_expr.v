module ast

import lib.comp.util

pub struct ExprStmt {
pub:
	// Node
	kind        SyntaxKind = .expr_stmt
	child_nodes []AstNode
	pos         util.Pos
	expr        Expr
}

pub fn new_expr_stmt(expr Expr) ExprStmt {
	return ExprStmt{
		expr: expr
		child_nodes: [AstNode(expr)]
	}
}

pub fn (bs &ExprStmt) child_nodes() []AstNode {
	return bs.child_nodes
}
