module ast

import lib.comp.token
import lib.comp.util

// Support range expr
//	ex: 1..10
pub struct RangeExpr {
pub:
	kind  SyntaxKind = .range_expr
	pos   util.Pos
	nodes []AstNode

	range token.Token
	from  Expr
	to    Expr
}

pub fn new_range_expr(from Expr, range token.Token, to Expr) RangeExpr {
	return RangeExpr{
		range: range
		from: from
		to: to
		pos: util.new_pos_from_pos_bounds(range.pos, to.pos())
		nodes: [AstNode(from), range, to]
	}
}

pub fn (iss &RangeExpr) child_nodes() []AstNode {
	return iss.nodes
}
