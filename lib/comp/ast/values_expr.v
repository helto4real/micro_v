module ast

import lib.comp.token

pub struct NumberExp {
	tok  token.Token
mut:
	iter_pos int
pub: 
	kind  SyntaxKind = .number_expr
	val   int
}

pub fn new_number_expression(tok token.Token, val int) NumberExp {
	if tok.kind != .number {
		panic('Expected a number token')
	}
	return NumberExp{
		tok: tok
		val: val
	}
}

// iterator support for tree walking
pub fn (mut ne NumberExp) next() ?AstNode {
	if ne.iter_pos == 0 {
		ne.iter_pos++
		return ne.tok
	}
	ne.iter_pos = 0
	return none
}

pub fn (mut ne NumberExp) child_nodes() []AstNode {
	mut nodes := []AstNode{cap:1}
	nodes << ne.tok
	return nodes
}