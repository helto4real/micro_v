module binding

import lib.comp.symbols

pub struct EmptyExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
}

pub fn new_empty_expr() BoundExpr {
	return EmptyExpr{
		typ: symbols.none_symbol
		kind: .none_expr
	}
}

pub fn (ex EmptyExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex EmptyExpr) str() string {
	return '<empty>'
}
