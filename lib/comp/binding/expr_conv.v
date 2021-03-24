module binding

import lib.comp.symbols

pub struct BoundConvExpr {
pub:
	kind        BoundNodeKind = .conv_expr
	typ         symbols.BuiltInTypeSymbol
	child_nodes []BoundNode
	expr        BoundExpr
}

pub fn new_bound_conv_expr(typ symbols.BuiltInTypeSymbol, expr BoundExpr) BoundExpr {
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
