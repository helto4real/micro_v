module ast

import lib.comp.token

pub const (
	binary_expression_tokens = [token.Kind(token.Kind.plus), .minus, .mul, .div, .amp_amp, .pipe_pipe]
	unary_expression_tokens  = [token.Kind(token.Kind.plus), .minus, .not]
)

pub struct BinaryExpr {
pub:
	left  Expression
	op    token.Token
	right Expression
	kind  SyntaxKind = .binary_expr
}

// new_binary_expression instance an binary expression 
// with a left side, right side and operator
pub fn new_binary_expression(left Expression, op token.Token, right Expression) BinaryExpr {
	if !(op.kind in ast.binary_expression_tokens) {
		panic('Expected a binary expresson token, got ($op.kind)')
	}
	return BinaryExpr{
		left: left
		op: op
		right: right
	}
}

pub fn (mut be BinaryExpr) child_nodes() []AstNode {
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
}

// new_binary_expression instance an binary expression 
// with a left side, right side and operator
pub fn new_unary_expression(op token.Token, operand Expression) UnaryExpr {
	if !(op.kind in ast.unary_expression_tokens) {
		panic('Expected a unary expresson token, got ($op.kind)')
	}
	return UnaryExpr{
		op: op
		operand: operand
	}
}

pub fn (mut be UnaryExpr) child_nodes() []AstNode {
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
}

pub fn new_paranthesis_expression(open_para_token token.Token, expr Expression, close_para_token token.Token) ParaExpr {
	return ParaExpr{
		open_para_token: open_para_token
		close_para_token: close_para_token
		expr: expr
	}
}

pub fn (mut pe ParaExpr) child_nodes() []AstNode {
	mut nodes := []AstNode{cap: 3}
	nodes << pe.open_para_token
	nodes << pe.expr
	nodes << pe.close_para_token
	return nodes
}
