module ast

import lib.comp.token
import lib.comp.types 
import lib.comp.util

pub struct LiteralExpr {
	tok  token.Token
pub: 
	kind  SyntaxKind = .literal_expr
	val   types.LitVal
	pos   util.Pos
}

pub fn new_literal_expr(tok token.Token, val types.LitVal) LiteralExpr {
	if tok.kind !in [.number, .key_true, .key_false] {
		panic('Expected a number token')
	}
	return LiteralExpr{
		tok: tok
		val: val
		pos: tok.pos
	}
}

pub fn (le &LiteralExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap:1}
	nodes << le.tok
	return nodes
}

pub struct NameExpr {
pub:
	kind  SyntaxKind = .name_expr
	ident_tok token.Token
	pos util.Pos
}

pub fn new_name_expr(ident_tok token.Token) NameExpr {
	return NameExpr {
		ident_tok: ident_tok
		pos: ident_tok.pos
	}
}

pub fn (ne &NameExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 1}
	nodes << ne.ident_tok
	return nodes
}