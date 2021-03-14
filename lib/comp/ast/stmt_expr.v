module ast

import lib.comp.util.source

pub struct ExprStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .expr_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	expr Expr
}

pub fn new_expr_stmt(tree &SyntaxTree, expr Expr) ExprStmt {
	return ExprStmt{
		tree: tree
		pos: expr.pos
		child_nodes: [AstNode(expr)]
		expr: expr
	}
}

pub fn (e &ExprStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ExprStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ExprStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex ExprStmt) str() string {
	return '$ex.expr'
}
