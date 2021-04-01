module ast

import lib.comp.util.source
import lib.comp.token

pub struct ReturnStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .return_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	has_expr   bool
	return_key token.Token
	expr       Expr
}

pub fn new_return_with_expr_stmt(tree &SyntaxTree, return_key token.Token, expr Expr) ReturnStmt {
	return ReturnStmt{
		tree: tree
		pos: return_key.pos
		child_nodes: [AstNode(return_key), expr]
		return_key: return_key
		expr: expr
		has_expr: true
	}
}

pub fn new_return_stmt(tree &SyntaxTree, return_key token.Token) ReturnStmt {
	return ReturnStmt{
		tree: tree
		pos: return_key.pos
		child_nodes: [AstNode(return_key)]
		return_key: return_key
		has_expr: false
	}
}

pub fn (e &ReturnStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ReturnStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ReturnStmt) node_str() string {
	return typeof(ex).name
}
