module binding

import lib.comp.symbols

pub struct BoundNoneExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .error_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
}

pub fn new_bound_emtpy_expr() BoundExpr {
	return BoundNoneExpr{
		typ: symbols.error_symbol
	}
}

pub fn (ex BoundNoneExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundNoneExpr) str() string {
	return '<empty>'
}
