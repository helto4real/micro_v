module ast

import lib.comp.token
import lib.comp.util

// Support if expression syntax
//	x := if i < 100 {10} else {20}
pub struct IfExpr {
pub:
	kind  SyntaxKind = .if_expr
	pos   util.Pos
	nodes []AstNode

	key_if    token.Token
	key_else  token.Token
	cond      Expr
	then_stmt Stmt
	else_stmt Stmt
}

pub fn new_if_expr(key_if token.Token, cond Expr, then_stmt Stmt, key_else token.Token, else_stmt Stmt) IfExpr {
	return IfExpr{
		key_if: key_if
		key_else: key_else
		cond: cond
		then_stmt: then_stmt
		else_stmt: else_stmt
		pos: util.new_pos_from_pos_bounds(key_if.pos, else_stmt.pos())
		nodes: [AstNode(key_if), cond, then_stmt, key_else, else_stmt]
	}
}

pub fn (iss &IfExpr) child_nodes() []AstNode {
	return iss.nodes
}
