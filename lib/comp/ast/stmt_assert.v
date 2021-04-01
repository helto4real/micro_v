module ast

import lib.comp.util.source
import lib.comp.token

pub struct AssertStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .assert_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	assert_key token.Token
	expr       Expr
}

pub fn new_assert_stmt(tree &SyntaxTree, assert_key token.Token, expr Expr) AssertStmt {
	return AssertStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(assert_key.pos, expr.pos)
		child_nodes: [AstNode(assert_key), expr]
		assert_key: assert_key
		expr: expr
	}
}

pub fn (e &AssertStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex AssertStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex AssertStmt) node_str() string {
	return typeof(ex).name
}
