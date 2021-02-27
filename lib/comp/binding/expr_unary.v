module binding

import lib.comp.types

pub struct BoundUnaryExpression {
pub:
	kind        BoundNodeKind
	typ         types.Type
	child_nodes []BoundNode
	op          BoundUnaryOperator
	operand     BoundExpr
}

fn new_bound_unary_expr(op BoundUnaryOperator, operand BoundExpr) BoundExpr {
	return BoundUnaryExpression{
		child_nodes: [BoundNode(operand)]
		kind: .unary_expr
		typ: op.res_typ
		op: op
		operand: operand
	}
}

pub fn (ex &BoundUnaryExpression) node_str() string {
	return typeof(ex).name
}
