module ast

import lib.comp.token
import lib.comp.util

pub const (
	binary_expr_tokens = [token.Kind(token.Kind.plus), .minus, .mul, .div, .amp_amp, .pipe_pipe,
								.eq_eq, .exl_mark_eq]
	unary_expr_tokens  = [token.Kind(token.Kind.plus), .minus, .exl_mark]
)

pub struct BinaryExpr {
pub:
	left  Expression
	op    token.Token
	right Expression
	kind  SyntaxKind = .binary_expr
	pos   util.Pos
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_binary_expr(left Expression, op token.Token, right Expression) BinaryExpr {
	if !(op.kind in ast.binary_expr_tokens) {
		panic('Expected a binary expresson token, got ($op.kind)')
	}
	return BinaryExpr{
		left: left
		op: op
		right: right
		pos: util.new_pos_from_bounds(left.pos(), right.pos())
	}
}

pub fn (be &BinaryExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << be.left
	nodes << be.op
	nodes << be.right
	return nodes
}

pub struct UnaryExpr {
pub:
	op      token.Token
	operand Expression
	kind    SyntaxKind = .unary_expr
	pos   	util.Pos
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_unary_expr(op token.Token, operand Expression) UnaryExpr {
	if !(op.kind in ast.unary_expr_tokens) {
		panic('Expected a unary expresson token, got ($op.kind)')
	}
	return UnaryExpr{
		op: op
		operand: operand
		pos: util.new_pos_from_bounds(op.pos, operand.pos())
	}
}

pub fn (be &UnaryExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << be.op
	nodes << be.operand
	return nodes
}

pub struct ParaExpr {
pub:
	kind             SyntaxKind = .para_expr
	open_para_token  token.Token
	close_para_token token.Token
	expr             Expression
	pos   			 util.Pos
}

pub fn new_paranthesis_expr(open_para_token token.Token, expr Expression, close_para_token token.Token) ParaExpr {
	return ParaExpr{
		open_para_token: open_para_token
		close_para_token: close_para_token
		expr: expr
		pos: util.new_pos_from_bounds(open_para_token.pos, close_para_token.pos)
	}
}

pub fn (pe &ParaExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << pe.open_para_token
	nodes << pe.expr
	nodes << pe.close_para_token
	return nodes
}
