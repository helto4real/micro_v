module binding

import lib.comp.symbols
import lib.comp.token

pub struct BoundUnaryExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	op          BoundUnaryOperator
	operand     BoundExpr
}

pub fn new_bound_unary_expr(op BoundUnaryOperator, operand BoundExpr) BoundExpr {
	return BoundUnaryExpr{
		child_nodes: [BoundNode(operand)]
		kind: .unary_expr
		typ: op.res_typ
		op: op
		operand: operand
	}
}

pub fn (ex &BoundUnaryExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex &BoundUnaryExpr) str() string {
	return '${token.token_str[ex.op.kind]}$ex.operand'
}
