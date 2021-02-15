module ast

import lib.comp.token

pub struct AssignExpr {
pub:
	kind   SyntaxKind = .assign_expr
	ident  token.Token
	eq_tok token.Token
	expr   Expression
}

pub fn new_assign_expr(ident token.Token, eq_tok token.Token, expr Expression) AssignExpr {
	return AssignExpr{
		ident: ident
		expr: expr
		eq_tok: eq_tok
	}
}

pub fn (mut ae AssignExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << ae.ident
	nodes << ae.eq_tok
	nodes << ae.expr
	return nodes
}
