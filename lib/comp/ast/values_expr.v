module ast

import lib.comp.token

pub struct LiteralExpr {
	tok  token.Token
pub: 
	kind  SyntaxKind = .literal_expr
	val   int
}

pub fn new_literal_expression(tok token.Token, val int) LiteralExpr {
	if tok.kind != .number {
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