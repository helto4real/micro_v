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
	tok_assert token.Token
	expr   		Expr
}

pub fn new_assert_stmt(tree &SyntaxTree, tok_assert token.Token, expr Expr) AssertStmt {
	return AssertStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(tok_assert.pos, expr.pos)
		child_nodes: [AstNode(tok_assert), expr]
		tok_assert: tok_assert
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
