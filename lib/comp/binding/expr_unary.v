module binding

import lib.comp.symbols
import lib.comp.token

pub struct BoundUnaryExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .unary_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
	// child nodes
	op           BoundUnaryOperator
	operand_expr BoundExpr
}

pub fn new_bound_unary_expr(op BoundUnaryOperator, operand_expr BoundExpr) BoundExpr {
	return BoundUnaryExpr{
		typ: op.res_typ
		op: op
		operand_expr: operand_expr
		child_nodes: [BoundNode(operand_expr)]
	}
}

pub fn (ex BoundUnaryExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundUnaryExpr) str() string {
	return '${token.token_str[ex.op.kind]}$ex.operand_expr'
}

pub fn (ex BoundUnaryExpr) to_ref_type() BoundUnaryExpr {
	return BoundUnaryExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}
