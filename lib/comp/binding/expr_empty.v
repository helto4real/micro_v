module binding

import lib.comp.symbols

pub struct BoundEmptyExpr {
pub:
	kind        BoundNodeKind = .error_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
}

pub fn new_bound_emtpy_expr() BoundExpr {
	return BoundEmptyExpr{
		typ: symbols.error_symbol
	}
}

pub fn (ex &BoundEmptyExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex &BoundEmptyExpr) str() string {
	return '<empty>'
}
