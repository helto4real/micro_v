module ast

import lib.comp.token
import lib.comp.util.source

// Support range expr
//	ex: 1..10
pub struct RangeExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .range_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	range     token.Token
	from_expr Expr
	to_expr   Expr
}

pub fn new_range_expr(tree &SyntaxTree, from_expr Expr, range token.Token, to_expr Expr) RangeExpr {
	return RangeExpr{
		tree: tree
		range: range
		from_expr: from_expr
		to_expr: to_expr
		pos: source.new_pos_from_pos_bounds(range.pos, to_expr.pos)
		child_nodes: [AstNode(from_expr), range, to_expr]
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
	return '${ex.from_expr}..$ex.to_expr'
}
