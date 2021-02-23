module ast

import lib.comp.token
import lib.comp.util

pub struct AssignExpr {
pub:
	kind   SyntaxKind = .assign_expr
	nodes []AstNode

	ident  token.Token
	eq_tok token.Token
	expr   Expr
	pos    util.Pos
}

pub fn new_assign_expr(ident token.Token, eq_tok token.Token, expr Expr) AssignExpr {
	return AssignExpr{
		ident: ident
		expr: expr
		eq_tok: eq_tok
		pos: util.new_pos_from_pos_bounds(ident.pos, expr.pos())
		nodes:[AstNode(ident), eq_tok, expr]
	}
}

pub fn (ae &AssignExpr) child_nodes() []AstNode {
	return ae.nodes
}
