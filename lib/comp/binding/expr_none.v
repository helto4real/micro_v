module binding

import lib.comp.symbols

pub struct NoneExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .none_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
}

pub fn new_empty_expr() BoundExpr {
	return NoneExpr{
		typ: symbols.none_symbol
	}
}

pub fn (ex NoneExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex NoneExpr) str() string {
	return '<none>'
}
