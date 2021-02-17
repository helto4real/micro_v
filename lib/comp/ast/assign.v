module ast

import lib.comp.token
import lib.comp.util

pub struct AssignExpr {
pub:
	kind   SyntaxKind = .assign_expr
	is_mut bool
	ident  token.Token
	eq_tok token.Token
	expr   Expression
	pos    util.Pos
}

pub fn new_assign_expr(ident token.Token, is_mut bool, eq_tok token.Token, expr Expression) AssignExpr {
	return AssignExpr{
		ident: ident
		expr: expr
		eq_tok: eq_tok
		is_mut: is_mut
		pos: util.new_pos_from_bounds(ident.pos, expr.pos())
	}
}

pub fn (ae &AssignExpr) child_nodes() []AstNode {
	println('ASSIGN_CHILD_NODE_FN')
	mut nodes := []AstNode{cap: 3}
	nodes << ae.ident
	nodes << ae.eq_tok
	nodes << ae.expr
	return nodes
}
