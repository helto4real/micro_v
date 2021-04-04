module binding

import lib.comp.symbols

pub struct NoneExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .none_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
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

pub fn (ex NoneExpr) to_ref_type() NoneExpr {
	return NoneExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}
