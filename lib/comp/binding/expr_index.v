module binding

import lib.comp.symbols

pub struct BoundIndexExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .index_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
	// child nodes
	left_expr BoundExpr
	index_expr BoundExpr
}

pub fn new_bound_index_expr(left_expr BoundExpr, index_expr BoundExpr) BoundExpr {
	return BoundIndexExpr{
		child_nodes: [BoundNode(left_expr), index_expr]
		typ: index_expr.typ
		left_expr: left_expr
		index_expr: index_expr
	}
}

pub fn (ex BoundIndexExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundIndexExpr) str() string {
	return '[$ex.index_expr]'
}

pub fn (ex BoundIndexExpr) to_ref_type() BoundIndexExpr {
	return BoundIndexExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}
