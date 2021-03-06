module ast

import lib.comp.token
import lib.comp.util.source

// Support range expr
//	ex: 1..10
pub struct RangeExpr {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .range_expr
	pos         source.Pos
	child_nodes []AstNode

	range token.Token
	from  Expr
	to    Expr
}

pub fn new_range_expr(tree &SyntaxTree, from Expr, range token.Token, to Expr) RangeExpr {
	return RangeExpr{
		tree: tree
		range: range
		from: from
		to: to
		pos: source.new_pos_from_pos_bounds(range.pos, to.pos)
		child_nodes: [AstNode(from), range, to]
	}
}

pub fn (iss &RangeExpr) child_nodes() []AstNode {
	return iss.child_nodes
}

pub fn (ex RangeExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex RangeExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex RangeExpr) str() string {
	return '${ex.from}..$ex.to'
}
