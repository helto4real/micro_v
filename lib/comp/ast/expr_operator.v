module ast

import lib.comp.token
import lib.comp.util.source

pub const (
	binary_expr_tokens = [token.Kind(token.Kind.plus), .minus, .mul, .div, .amp_amp, .pipe_pipe,
		.eq_eq, .exl_mark_eq, .lt, .gt, .lt_eq, .gt_eq, .amp, .pipe, .hat]
	unary_expr_tokens  = [token.Kind(token.Kind.plus), .minus, .exl_mark, .tilde]
)

pub struct BinaryExpr {
pub:
	tree        &SyntaxTree
	left        Expr
	op          token.Token
	right       Expr
	kind        SyntaxKind = .binary_expr
	pos         source.Pos
	child_nodes []AstNode
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_binary_expr(tree &SyntaxTree, left Expr, op token.Token, right Expr) BinaryExpr {
	if !(op.kind in ast.binary_expr_tokens) {
		panic('Expected a binary expresson token, got ($op.kind)')
	}
	return BinaryExpr{
		tree: tree
		left: left
		op: op
		right: right
		pos: source.new_pos_from_pos_bounds(left.pos, right.pos)
		child_nodes: [AstNode(left), op, right]
	}
}

pub fn (be &BinaryExpr) child_nodes() []AstNode {
	return be.child_nodes
}

pub fn (ex BinaryExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex BinaryExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BinaryExpr) str() string {
	return '$ex.left $ex.op.lit $ex.right'
}

pub struct UnaryExpr {
pub:
	tree        &SyntaxTree
	op          token.Token
	operand     Expr
	kind        SyntaxKind = .unary_expr
	pos         source.Pos
	child_nodes []AstNode
}

// new_binary_expr instance an binary expression 
// with a left side, right side and operator
pub fn new_unary_expr(tree &SyntaxTree, op token.Token, operand Expr) UnaryExpr {
	if !(op.kind in ast.unary_expr_tokens) {
		panic('Expected a unary expresson token, got ($op.kind)')
	}
	return UnaryExpr{
		tree: tree
		op: op
		operand: operand
		pos: source.new_pos_from_pos_bounds(op.pos, operand.pos)
		child_nodes: [AstNode(op), operand]
	}
}

pub fn (be &UnaryExpr) child_nodes() []AstNode {
	return be.child_nodes
}

pub fn (ex UnaryExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex UnaryExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex UnaryExpr) str() string {
	return '$ex.op.lit$ex.operand'
}

pub struct ParaExpr {
pub:
	tree             &SyntaxTree
	kind             SyntaxKind = .para_expr
	open_para_token  token.Token
	close_para_token token.Token
	expr             Expr
	pos              source.Pos
	child_nodes      []AstNode
}

pub fn new_paranthesis_expr(tree &SyntaxTree, open_para_token token.Token, expr Expr, close_para_token token.Token) ParaExpr {
	return ParaExpr{
		tree: tree
		open_para_token: open_para_token
		close_para_token: close_para_token
		expr: expr
		pos: source.new_pos_from_pos_bounds(open_para_token.pos, close_para_token.pos)
		child_nodes: [AstNode(open_para_token), expr, close_para_token]
	}
}

pub fn (pe &ParaExpr) child_nodes() []AstNode {
	return pe.child_nodes
}

pub fn (ex ParaExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ParaExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex ParaExpr) str() string {
	return '($ex.expr)'
}
