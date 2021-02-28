module binding

import lib.comp.ast
import lib.comp.types
import lib.comp.token

const (
	bound_unary_operators  = build_bound_unary_operators()
	bound_binary_operators = build_bound_binary_operators()
)

pub struct BoundUnaryOperator {
pub:
	op_kind BoundUnaryOperatorKind
	kind    token.Kind
	op_typ  types.Type
	res_typ types.Type
}

pub fn new_bound_unary_op(kind token.Kind, op_kind BoundUnaryOperatorKind, op_typ types.Type) BoundUnaryOperator {
	return new_bound_unary_op_with_ret(kind, op_kind, op_typ, types.Type(0))
}

pub fn new_bound_unary_op_with_ret(kind token.Kind, op_kind BoundUnaryOperatorKind, op_typ types.Type, res_typ types.Type) BoundUnaryOperator {
	return BoundUnaryOperator{
		kind: kind
		op_kind: op_kind
		op_typ: op_typ
		res_typ: res_typ
	}
}
pub fn (ex &BoundUnaryOperator) node_str() string {
	return typeof(ex).name
}

fn build_bound_unary_operators() []BoundUnaryOperator {
	mut operators := []BoundUnaryOperator{}

	operators << new_bound_unary_op(.exl_mark, .logic_negation, int(types.TypeKind.bool_lit))
	operators << new_bound_unary_op(.plus, .identity, int(types.TypeKind.int_lit))
	operators << new_bound_unary_op(.minus, .negation, int(types.TypeKind.int_lit))

	operators << new_bound_unary_op(.tilde, .ones_compl, int(types.TypeKind.int_lit))

	return operators
}

pub fn bind_unary_operator(kind token.Kind, op_typ types.Type) ?BoundUnaryOperator {
	for op in binding.bound_unary_operators {
		if op.kind == kind && op.op_typ == op_typ {
			return op
		}
	}
	return none
}

//-----------------------------------------------

pub struct BoundBinaryOperator {
pub:
	op_kind   BoundBinaryOperatorKind
	kind      token.Kind
	left_typ  types.Type
	right_typ types.Type
	res_typ   types.Type
}

pub fn new_bound_binary_op_full(kind token.Kind, op_kind BoundBinaryOperatorKind, left_typ types.Type, right_typ types.Type, res_typ types.Type) BoundBinaryOperator {
	return BoundBinaryOperator{
		kind: kind
		op_kind: op_kind
		left_typ: left_typ
		right_typ: right_typ
		res_typ: res_typ
	}
}

pub fn (ex &BoundBinaryOperator) node_str() string {
	return typeof(ex).name
}

pub fn new_bound_binary_op(kind token.Kind, op_kind BoundBinaryOperatorKind, typ types.Type) BoundBinaryOperator {
	return new_bound_binary_op_full(kind, op_kind, typ, typ, typ)
}

pub fn new_bound_binary_op_with_res(kind token.Kind, op_kind BoundBinaryOperatorKind, op_typ types.Type, res_typ types.Type) BoundBinaryOperator {
	return new_bound_binary_op_full(kind, op_kind, op_typ, op_typ, res_typ)
}

fn build_bound_binary_operators() []BoundBinaryOperator {
	mut operators := []BoundBinaryOperator{}

	// int
	operators << new_bound_binary_op(.plus, .addition, int(types.TypeKind.int_lit))
	operators << new_bound_binary_op(.minus, .subraction, int(types.TypeKind.int_lit))
	operators << new_bound_binary_op(.mul, .multiplication, int(types.TypeKind.int_lit))
	operators << new_bound_binary_op(.div, .divition, int(types.TypeKind.int_lit))

	operators << new_bound_binary_op(.amp, .bitwise_and, int(types.TypeKind.int_lit))
	operators << new_bound_binary_op(.pipe, .bitwise_or, int(types.TypeKind.int_lit))
	operators << new_bound_binary_op(.hat, .bitwise_xor, int(types.TypeKind.int_lit))

	// strings
	operators << new_bound_binary_op(.plus, .str_concat, int(types.TypeKind.string_lit))

	// accept int but returns bool
	operators << new_bound_binary_op_with_res(.eq_eq, .equals, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op_with_res(.exl_mark_eq, .not_equals, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))

	operators << new_bound_binary_op(.amp_amp, .logic_and, int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op(.pipe_pipe, .logic_or, int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op(.eq_eq, .equals, int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op(.exl_mark_eq, .not_equals, int(types.TypeKind.bool_lit))

	operators << new_bound_binary_op_with_res(.lt, .less, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op_with_res(.gt, .greater, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op_with_res(.lt_eq, .less_or_equals, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))
	operators << new_bound_binary_op_with_res(.gt_eq, .greater_or_equals, int(types.TypeKind.int_lit),
		int(types.TypeKind.bool_lit))
	return operators
}

pub fn bind_binary_operator(kind token.Kind, left_typ types.Type, right_typ types.Type) ?BoundBinaryOperator {
	for op in binding.bound_binary_operators {
		if op.kind == kind && op.left_typ == left_typ && op.right_typ == right_typ {
			return op
		}
	}
	return none
}

pub enum BoundUnaryOperatorKind {
	identity
	negation
	logic_negation
	ones_compl
	not_supported
}

pub enum BoundBinaryOperatorKind {
	addition
	subraction
	multiplication
	divition
	equals
	not_equals
	less
	greater
	less_or_equals
	greater_or_equals
	logic_and
	logic_or
	bitwise_and
	bitwise_or
	bitwise_xor
	str_concat
	not_supported
}

fn (mut b Binder) bind_unary_expr(syntax ast.UnaryExpr) BoundExpr {
	bound_operand := b.bind_expr(syntax.operand)
	bound_op := bind_unary_operator(syntax.op.kind, bound_operand.typ()) or {
		b.log.error('unary operator $syntax.op.lit is not defined for type ${bound_operand.typ_str()}.',
			syntax.op.pos)
		return bound_operand
	}
	return new_bound_unary_expr(bound_op, bound_operand)
}

fn (mut b Binder) bind_binary_expr(syntax ast.BinaryExpr) BoundExpr {
	bound_left := b.bind_expr(syntax.left)
	bound_right := b.bind_expr(syntax.right)
	bound_op := bind_binary_operator(syntax.op.kind, bound_left.typ(), bound_right.typ()) or {
		b.log.error('binary operator $syntax.op.lit is not defined for types $bound_left.typ_str() and ${bound_right.typ_str()}.',
			syntax.op.pos)
		return bound_left
	}
	return new_bound_binary_expr(bound_left, bound_op, bound_right)
}

