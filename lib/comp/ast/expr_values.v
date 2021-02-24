module ast

import lib.comp.token
import lib.comp.types
import lib.comp.util

pub struct LiteralExpr {
	tok token.Token
pub:
	kind        SyntaxKind = .literal_expr
	val         types.LitVal
	pos         util.Pos
	child_nodes []AstNode
}

pub fn new_literal_expr(tok token.Token, val types.LitVal) LiteralExpr {
	if tok.kind !in [.number, .key_true, .key_false] {
		panic('Expected a number token')
	}
	return LiteralExpr{
		tok: tok
		val: val
		pos: tok.pos
		child_nodes: [AstNode(tok)]
	}
}

pub fn (le &LiteralExpr) child_nodes() []AstNode {
	return le.child_nodes
}

pub struct NameExpr {
pub:
	kind        SyntaxKind = .name_expr
	ident   token.Token
	pos         util.Pos
	child_nodes []AstNode
}

pub fn new_name_expr(ident token.Token) NameExpr {
	return NameExpr{
		ident: ident
		pos: ident.pos
		child_nodes: [AstNode(ident)]
	}
}

pub fn (ne &NameExpr) child_nodes() []AstNode {
	return ne.child_nodes
}
