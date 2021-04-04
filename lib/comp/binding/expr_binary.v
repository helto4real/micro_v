module binding

import lib.comp.symbols
import lib.comp.token

pub struct BoundBinaryExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .binary_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
	// child nodes
	left_expr  BoundExpr
	op         BoundBinaryOperator
	right_expr BoundExpr
}

pub fn new_bound_binary_expr(left_expr BoundExpr, op BoundBinaryOperator, right_expr BoundExpr) BoundExpr {
	return BoundBinaryExpr{
		typ: op.res_typ
		op: op
		left_expr: left_expr
		right_expr: right_expr
		child_nodes: [BoundNode(left_expr), right_expr]
	}
}

pub fn (ex BoundBinaryExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundBinaryExpr) str() string {
	return '$ex.left_expr ${token.token_str[ex.op.kind]} $ex.right_expr'
}

pub fn (ex BoundBinaryExpr) to_ref_type() BoundBinaryExpr {
	return BoundBinaryExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}
