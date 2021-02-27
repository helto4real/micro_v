module binding

import lib.comp.types

pub struct BoundBinaryExpr {
pub:
	kind        BoundNodeKind
	typ         types.Type
	child_nodes []BoundNode
	left        BoundExpr
	op          BoundBinaryOperator
	right       BoundExpr
}

pub fn new_bound_binary_expr(left BoundExpr, op BoundBinaryOperator, right BoundExpr) BoundExpr {
	return BoundBinaryExpr{
		child_nodes: [BoundNode(left), right]
		kind: .binary_expr
		typ: op.res_typ
		op: op
		left: left
		right: right
	}
}

pub fn (ex &BoundBinaryExpr) node_str() string {
	return typeof(ex).name
}