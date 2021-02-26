module binding

import lib.comp.types

struct BoundLiteralExpr {
pub:
	kind        BoundNodeKind
	typ         types.Type
	child_nodes []BoundNode
	val         types.LitVal
}

fn new_bound_literal_expr(val types.LitVal) BoundExpr {
	return BoundLiteralExpr{
		typ: val.typ()
		kind: .literal_expr
		val: val
	}
}
pub fn (ex &BoundLiteralExpr) node_str() string {
	return typeof(ex).name
}