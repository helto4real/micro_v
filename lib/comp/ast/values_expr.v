module ast

import lib.comp.token
import lib.comp.types 

pub struct LiteralExpr {
	tok  token.Token
pub: 
	kind  SyntaxKind = .literal_expr
	val   types.LitVal
}

pub fn new_literal_expression(tok token.Token, val types.LitVal) LiteralExpr {
	if tok.kind !in [.number, .key_true, .key_false] {
		panic('Expected a number token')
	}
	return LiteralExpr{
		tok: tok
		val: val
	}
}

pub fn (mut le LiteralExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap:1}
	nodes << le.tok
	return nodes
}