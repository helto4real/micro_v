module binding

import lib.comp.symbols

pub struct BoundRangeExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .range_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	from_expr BoundExpr
	to_expr   BoundExpr
}

fn new_range_expr(from_expr BoundExpr, to_expr BoundExpr) BoundExpr {
	return BoundRangeExpr{
		child_nodes: [BoundNode(from_expr), to_expr]
		typ: from_expr.typ
		from_expr: from_expr
		to_expr: to_expr
	}
}

pub fn (ex BoundRangeExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundRangeExpr) str() string {
	return '${ex.from_expr}..$ex.to_expr'
}
