module ast

import lib.comp.token
import lib.comp.util

pub const (
	binary_expr_tokens = [token.Kind(token.Kind.plus), .minus, .mul, .div, .amp_amp, .pipe_pipe,
		.eq_eq, .exl_mark_eq, .lt, .gt, .lt_eq, .gt_eq]
	unary_expr_tokens  = [token.Kind(token.Kind.plus), .minus, .exl_mark]
)

pub struct BinaryExpr {
pub:
	left        Expr
	op          token.Token
	right       Expr
	kind        SyntaxKind = .binary_expr
	pos         util.Pos
	child_nodes []AstNode
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_binary_expr(left Expr, op token.Token, right Expr) BinaryExpr {
	if !(op.kind in ast.binary_expr_tokens) {
		panic('Expected a binary expresson token, got ($op.kind)')
	}
	return BinaryExpr{
		left: left
		op: op
		right: right
		pos: util.new_pos_from_pos_bounds(left.pos(), right.pos())
		child_nodes: [AstNode(left), op, right]
	}
}

pub fn (be &BinaryExpr) child_nodes() []AstNode {
	return be.child_nodes
}

pub struct UnaryExpr {
pub:
	op          token.Token
	operand     Expr
	kind        SyntaxKind = .unary_expr
	pos         util.Pos
	child_nodes []AstNode
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_unary_expr(op token.Token, operand Expr) UnaryExpr {
	if !(op.kind in ast.unary_expr_tokens) {
		panic('Expected a unary expresson token, got ($op.kind)')
	}
	return UnaryExpr{
		op: op
		operand: operand
		pos: util.new_pos_from_pos_bounds(op.pos, operand.pos())
		child_nodes: [AstNode(op), operand]
	}
}

pub fn (be &UnaryExpr) child_nodes() []AstNode {
	return be.child_nodes
}

pub struct ParaExpr {
pub:
	kind             SyntaxKind = .para_expr
	open_para_token  token.Token
	close_para_token token.Token
	expr             Expr
	pos              util.Pos
	child_nodes      []AstNode
}

pub fn new_paranthesis_expr(open_para_token token.Token, expr Expr, close_para_token token.Token) ParaExpr {
	return ParaExpr{
		open_para_token: open_para_token
		close_para_token: close_para_token
		expr: expr
		pos: util.new_pos_from_pos_bounds(open_para_token.pos, close_para_token.pos)
		child_nodes: [AstNode(open_para_token), expr, close_para_token]
	}
}

pub fn (pe &ParaExpr) child_nodes() []AstNode {
	return pe.child_nodes
}
