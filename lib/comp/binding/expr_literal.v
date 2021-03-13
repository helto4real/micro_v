module binding

import lib.comp.symbols
import lib.comp.types

pub struct BoundLiteralExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	val         types.LitVal
}

pub fn new_bound_literal_expr(val types.LitVal) BoundExpr {
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
