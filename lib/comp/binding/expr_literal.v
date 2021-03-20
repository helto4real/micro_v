module binding

import lib.comp.symbols

pub struct BoundLiteralExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	val         symbols.LitVal
}

pub fn new_bound_literal_expr(val symbols.LitVal) BoundExpr {
	return BoundLiteralExpr{
		typ: val.typ()
		kind: .literal_expr
		val: val
	}
}

pub fn (ex BoundLiteralExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundLiteralExpr) str() string {
	return '$ex.val'
}
