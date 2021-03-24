module binding

import lib.comp.ast
import lib.comp.symbols
import lib.comp.token

pub const (
	bound_unary_operators  = build_bound_unary_operators()
	bound_binary_operators = build_bound_binary_operators()
)

pub struct BoundUnaryOperator {
pub:
	op_kind BoundUnaryOperatorKind
	kind    token.Kind
	op_typ  symbols.BuiltInTypeSymbol
	res_typ symbols.BuiltInTypeSymbol
}

pub fn new_bound_unary_op(kind token.Kind, op_kind BoundUnaryOperatorKind, op_typ symbols.BuiltInTypeSymbol) BoundUnaryOperator {
	return new_bound_unary_op_with_ret(kind, op_kind, op_typ, op_typ)
}

pub fn new_bound_unary_op_with_ret(kind token.Kind, op_kind BoundUnaryOperatorKind, op_typ symbols.BuiltInTypeSymbol, res_typ symbols.BuiltInTypeSymbol) BoundUnaryOperator {
	return BoundUnaryOperator{
		kind: kind
		op_kind: op_kind
		op_typ: op_typ
		res_typ: res_typ
	}
}

pub fn (ex BoundUnaryOperator) node_str() string {
	return typeof(ex).name
}

fn build_bound_unary_operators() []BoundUnaryOperator {
	mut operators := []BoundUnaryOperator{}

	operators << new_bound_unary_op(.exl_mark, .logic_negation, symbols.bool_symbol)
	operators << new_bound_unary_op(.plus, .identity, symbols.int_symbol)
	operators << new_bound_unary_op(.minus, .negation, symbols.int_symbol)

	operators << new_bound_unary_op(.tilde, .ones_compl, symbols.int_symbol)

	return operators
}

pub fn bind_unary_operator(kind token.Kind, op_typ symbols.BuiltInTypeSymbol) ?BoundUnaryOperator {
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
	left_typ  symbols.BuiltInTypeSymbol
	right_typ symbols.BuiltInTypeSymbol
	res_typ   symbols.BuiltInTypeSymbol
}

pub fn new_bound_binary_op_full(kind token.Kind, op_kind BoundBinaryOperatorKind, left_typ symbols.BuiltInTypeSymbol, right_typ symbols.BuiltInTypeSymbol, res_typ symbols.BuiltInTypeSymbol) BoundBinaryOperator {
	return BoundBinaryOperator{
		kind: kind
		op_kind: op_kind
		left_typ: left_typ
		right_typ: right_typ
		res_typ: res_typ
	}
}

pub fn (ex BoundBinaryOperator) node_str() string {
	return typeof(ex).name
}

pub fn new_bound_binary_op(kind token.Kind, op_kind BoundBinaryOperatorKind, typ symbols.BuiltInTypeSymbol) BoundBinaryOperator {
	return new_bound_binary_op_full(kind, op_kind, typ, typ, typ)
}

pub fn new_bound_binary_op_with_res(kind token.Kind, op_kind BoundBinaryOperatorKind, op_typ symbols.BuiltInTypeSymbol, res_typ symbols.BuiltInTypeSymbol) BoundBinaryOperator {
	return new_bound_binary_op_full(kind, op_kind, op_typ, op_typ, res_typ)
}

fn build_bound_binary_operators() []BoundBinaryOperator {
	mut operators := []BoundBinaryOperator{}

	// int
	operators << new_bound_binary_op(.plus, .addition, symbols.int_symbol)
	operators << new_bound_binary_op(.minus, .subraction, symbols.int_symbol)
	operators << new_bound_binary_op(.mul, .multiplication, symbols.int_symbol)
	operators << new_bound_binary_op(.div, .divition, symbols.int_symbol)

	operators << new_bound_binary_op(.amp, .bitwise_and, symbols.int_symbol)
	operators << new_bound_binary_op(.pipe, .bitwise_or, symbols.int_symbol)
	operators << new_bound_binary_op(.hat, .bitwise_xor, symbols.int_symbol)

	// any
	operators << new_bound_binary_op(.eq_eq, .equals, symbols.any_symbol)
	operators << new_bound_binary_op(.exl_mark_eq, .not_equals, symbols.any_symbol)

	// strings
	operators << new_bound_binary_op(.plus, .str_concat, symbols.string_symbol)
	operators << new_bound_binary_op_with_res(.eq_eq, .equals, symbols.string_symbol,
		symbols.bool_symbol)
	operators << new_bound_binary_op_with_res(.exl_mark_eq, .not_equals, symbols.string_symbol,
		symbols.bool_symbol)

	// accept int but returns bool
	operators << new_bound_binary_op_with_res(.eq_eq, .equals, symbols.int_symbol, symbols.bool_symbol)
	operators << new_bound_binary_op_with_res(.exl_mark_eq, .not_equals, symbols.int_symbol,
		symbols.bool_symbol)

	operators << new_bound_binary_op(.amp_amp, .logic_and, symbols.bool_symbol)
	operators << new_bound_binary_op(.pipe_pipe, .logic_or, symbols.bool_symbol)
	operators << new_bound_binary_op(.eq_eq, .equals, symbols.bool_symbol)
	operators << new_bound_binary_op(.exl_mark_eq, .not_equals, symbols.bool_symbol)

	operators << new_bound_binary_op_with_res(.lt, .less, symbols.int_symbol, symbols.bool_symbol)
	operators << new_bound_binary_op_with_res(.gt, .greater, symbols.int_symbol, symbols.bool_symbol)
	operators << new_bound_binary_op_with_res(.lt_eq, .less_or_equals, symbols.int_symbol,
		symbols.bool_symbol)
	operators << new_bound_binary_op_with_res(.gt_eq, .greater_or_equals, symbols.int_symbol,
		symbols.bool_symbol)
	return operators
}

pub fn bind_binary_operator(kind token.Kind, left_typ symbols.BuiltInTypeSymbol, right_typ symbols.BuiltInTypeSymbol) ?BoundBinaryOperator {
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
	if bound_operand.typ == symbols.error_symbol {
		return new_bound_error_expr()
	}
	bound_op := bind_unary_operator(syntax.op.kind, bound_operand.typ) or {
		b.log.error('unary operator $syntax.op.lit is not defined for type ${bound_operand.typ.name}.',
			syntax.op.text_location())
		return new_bound_error_expr()
	}
	return new_bound_unary_expr(bound_op, bound_operand)
}

fn (mut b Binder) bind_binary_expr(syntax ast.BinaryExpr) BoundExpr {
	bound_left := b.bind_expr(syntax.left)
	bound_right := b.bind_expr(syntax.right)

	if bound_left.typ == symbols.error_symbol || bound_right.typ == symbols.error_symbol {
		return new_bound_error_expr()
	}

	bound_op := bind_binary_operator(syntax.op.kind, bound_left.typ, bound_right.typ) or {
		b.log.error('binary operator $syntax.op.lit is not defined for types $bound_left.typ.name and ${bound_right.typ.name}.',
			syntax.op.text_location())
		return new_bound_error_expr()
	}
	return new_bound_binary_expr(bound_left, bound_op, bound_right)
}
