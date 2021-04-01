module binding

import lib.comp.symbols

pub struct BoundConvExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .conv_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	expr        BoundExpr
}

pub fn new_bound_conv_expr(typ symbols.TypeSymbol, expr BoundExpr) BoundExpr {
	return BoundConvExpr{
		child_nodes: [BoundNode(expr)]
		typ: typ
		expr: expr
	}
}

pub fn (ex BoundConvExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundConvExpr) str() string {
	return '${ex.typ.name}($ex.expr)'
}
