module ast

import lib.comp.token
import lib.comp.util

pub struct AssignExpr {
pub:
	kind   SyntaxKind = .assign_expr
	ident  token.Token
	eq_tok token.Token
	expr   ExpressionSyntax
	pos    util.Pos
}

pub fn new_assign_expr(ident token.Token, eq_tok token.Token, expr ExpressionSyntax) AssignExpr {
	return AssignExpr{
		ident: ident
		expr: expr
		eq_tok: eq_tok
		pos: util.new_pos_from_bounds(ident.pos, expr.pos())
	}
}

pub fn (ae &AssignExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << ae.ident
	nodes << ae.eq_tok
	nodes << ae.expr
	return nodes
}
