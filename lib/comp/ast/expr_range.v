module ast

import lib.comp.token
import lib.comp.util

// Support range expr
//	ex: 1..10
pub struct RangeExprSyntax {
pub:
	kind  SyntaxKind = .range_expr
	pos   util.Pos
	nodes []AstNode

	range_tok token.Token
	from_expr ExpressionSyntax
	to_expr   ExpressionSyntax
}

pub fn new_range_expr(range_tok token.Token, from_expr ExpressionSyntax, to_expr ExpressionSyntax, key_else_tok token.Token, else_stmt StatementSyntax) RangeExprSyntax {
	return RangeExprSyntax{
		range_tok: range_tok
		from_expr: from_expr
		to_expr: to_expr
		pos: util.new_pos_from_pos_bounds(range_tok.pos, to_expr.pos())
		nodes: [AstNode(range_tok), from_expr, to_expr]
	}
}

pub fn (iss &RangeExprSyntax) child_nodes() []AstNode {
	return iss.nodes
}
