module binding

import lib.comp.symbols

pub struct BoundErrorExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .error_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
}

pub fn new_bound_error_expr() BoundExpr {
	return BoundErrorExpr{
		typ: symbols.error_symbol
	}
}

pub fn (ex BoundErrorExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundErrorExpr) str() string {
	return '?'
}
