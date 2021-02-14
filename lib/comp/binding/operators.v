module binding

import lib.comp.ast
import lib.comp.types
import lib.comp.token

enum BoundUnaryOperatorKind {
	identity
	negation
	logic_negation
	not_supported
}

enum BoundBinaryOperatorKind {
	addition
	subraction
	multiplication
	divition
	logic_and
	logic_or
	not_supported
}

struct BoundUnaryExpression {
pub:
	kind    BoundNodeKind
	typ     types.Type
	op_kind BoundUnaryOperatorKind
	operand BoundExpr
}

fn new_bound_unary_expr(op_kind BoundUnaryOperatorKind, operand BoundExpr) BoundExpr {
	return BoundUnaryExpression{
		kind: .literal_expression
		typ: operand.typ()
		op_kind: op_kind
		operand: operand
	}
}

struct BoundBinaryExpr {
pub:
	kind    BoundNodeKind
	typ     types.Type
	op_kind BoundBinaryOperatorKind
	left    BoundExpr
	right   BoundExpr
}

fn new_bound_binary_expr(left BoundExpr, op_kind BoundBinaryOperatorKind, right BoundExpr) BoundExpr {
	return BoundBinaryExpr{
		kind: .binary_expr
		typ: left.typ()
		op_kind: op_kind
		left: left
		right: right
	}
}

struct BoundLiteralExpr {
pub:
	kind BoundNodeKind
	typ  types.Type
	val  types.LitVal
}

fn new_bound_literal_expr(val types.LitVal) BoundExpr {
	return BoundLiteralExpr{
		typ: val.typ()
		kind: .literal_expression
		val: val
	}
}

fn (mut b Binder) bind_unary_expr(syntax ast.UnaryExpr) BoundExpr {
	bound_operand := b.bind_expr(syntax.operand)
	bound_op_kind := b.bind_unary_op_kind(syntax.op.kind, bound_operand.typ())
	if bound_op_kind == .not_supported {
		b.error('Unary operator ${syntax.op.lit} is not defined for type ${bound_operand.typ_str()}.', syntax.op.pos)
		return bound_operand
	}
	return new_bound_unary_expr(bound_op_kind, bound_operand)
}

fn (mut b Binder) bind_binary_expr(syntax ast.BinaryExpr) BoundExpr {
	bound_left := b.bind_expr(syntax.left)
	bound_right := b.bind_expr(syntax.right)
	bound_op_kind := b.bind_binary_op_kind(syntax.op.kind, bound_left.typ(), bound_right.typ())
	if bound_op_kind == .not_supported {
		b.error('Binary operator ${syntax.op.lit} is not defined for types ${bound_left.typ_str()} and ${bound_right.typ_str()}.', syntax.op.pos)
		return bound_left
	}
	return new_bound_binary_expr(bound_left, bound_op_kind, bound_right)
}

fn (mut b Binder) bind_unary_op_kind(kind token.Kind, typ types.Type) BoundUnaryOperatorKind {
	if typ == int(types.TypeKind.int_lit) {
		match kind {
			.plus {
				return .identity
			}
			.minus {
				return .negation
			}
			else{/*just falls through to not supported*/}
		}
	} 
	
	if typ == int(types.TypeKind.bool_lit) {
		match kind {
			.not {
				return .logic_negation
			}
			else{/*just falls through to not supported*/}
		}		
	}
	return .not_supported
}

fn (mut b Binder) bind_binary_op_kind(kind token.Kind, left_typ types.Type, right_typ types.Type) BoundBinaryOperatorKind {
	int_type := int(types.TypeKind.int_lit)
	if left_typ == int_type && right_typ == int_type {
		match kind {
			.plus {
				return .addition
			}
			.minus {
				return .subraction
			}
			.mul {
				return .multiplication
			}
			.div {
				return .divition
			}
			else{/*just falls through to not supported*/}
		}
	}
	bool_type := int(types.TypeKind.bool_lit)
	if left_typ == bool_type && right_typ == bool_type {
		match kind {
			.amp_amp {
				return .logic_and
			}
			.pipe_pipe {
				return .logic_or
			}
			else{/*just falls through to not supported*/}
		}
	}
	return .not_supported
}
