module ast

import lib.comp.token
import lib.comp.types
import lib.comp.util.source

pub struct LiteralExpr {
	tok token.Token
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .literal_expr
	val         types.LitVal
	pos         source.Pos
	child_nodes []AstNode
}

pub fn new_literal_expr(tree &SyntaxTree, tok token.Token, val types.LitVal) LiteralExpr {
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

pub struct NameExpr {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .name_expr
	ident       token.Token
	pos         source.Pos
	child_nodes []AstNode
}

pub fn new_name_expr(tree &SyntaxTree, ident token.Token) NameExpr {
	return NameExpr{
		tree: tree
		ident: ident
		pos: ident.pos
		child_nodes: [AstNode(ident)]
	}
}

pub fn (ne &NameExpr) child_nodes() []AstNode {
	return ne.child_nodes
}

pub fn (ex NameExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex NameExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex NameExpr) str() string {
	return '$ex.ident.lit'
}
