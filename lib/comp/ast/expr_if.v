module ast

import lib.comp.token
import lib.comp.util

// Support if expression syntax
//	x := if i < 100 {10} else {20}
pub struct IfExprSyntax {
pub:
	kind   SyntaxKind = .if_expr
	pos    util.Pos
	nodes  []AstNode

	key_if_tok  token.Token
	cond   ExpressionSyntax
	then_stmt  StatementSyntax
	else_stmt  StatementSyntax
}

pub fn new_if_expr_stmt(key_if_tok token.Token, cond ExpressionSyntax, then_stmt StatementSyntax, else_stmt StatementSyntax) IfExprSyntax {
	return IfExprSyntax{
		key_if_tok: key_if_tok
		cond: cond
		then_stmt: then_stmt
		else_stmt: else_stmt
		pos: util.new_pos_from_pos_bounds(key_if_tok.pos, else_stmt.pos())
		nodes: [AstNode(key_if_tok), cond, then_stmt, else_stmt]
	}
}

pub fn (iss &IfExprSyntax) child_nodes() []AstNode {
	return iss.nodes
}

