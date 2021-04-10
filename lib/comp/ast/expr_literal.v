module ast

import lib.comp.token
import lib.comp.symbols
import lib.comp.util.source

pub struct LiteralExpr {
	tok token.Token
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .literal_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	val symbols.LitVal
}

pub fn new_literal_expr(tree &SyntaxTree, tok token.Token, val symbols.LitVal) LiteralExpr {
	if tok.kind !in [.number, .string, .key_true, .key_false] {
		panic('Expected a number token')
	}
	return LiteralExpr{
		tree: tree
		tok: tok
		val: val
		pos: tok.pos
		child_nodes: [AstNode(tok)]
	}
}

pub fn (le &LiteralExpr) child_nodes() []AstNode {
	return le.child_nodes
}

pub fn (ex LiteralExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex LiteralExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex LiteralExpr) str() string {
	return '$ex.val'
}
