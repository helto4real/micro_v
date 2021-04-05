module ast

import lib.comp.token
import lib.comp.util.source

pub const (
	binary_expr_tokens = [token.Kind(token.Kind.plus), .minus, .mul, .div, .amp_amp, .pipe_pipe,
		.eq_eq, .exl_mark_eq, .lt, .gt, .lt_eq, .gt_eq, .amp, .pipe, .hat, .lsbr]
	unary_expr_tokens  = [token.Kind(token.Kind.plus), .minus, .exl_mark, .tilde]
)

pub struct BinaryExpr {
pub:
	kind        SyntaxKind = .binary_expr
	pos         source.Pos
	tree        &SyntaxTree
	child_nodes []AstNode

	left_expr  Expr
	op_tok     token.Token
	right_expr Expr
}

// new_binary_expr instance an binary expression 
// with a left_expr side, right_expr side and operator
pub fn new_binary_expr(tree &SyntaxTree, left_expr Expr, op_tok token.Token, right_expr Expr) BinaryExpr {
	if !(op_tok.kind in ast.binary_expr_tokens) {
		panic('Expected a binary expresson token, got ($op_tok.kind)')
	}
	return BinaryExpr{
		tree: tree
		left_expr: left_expr
		op_tok: op_tok
		right_expr: right_expr
		pos: source.new_pos_from_pos_bounds(left_expr.pos, right_expr.pos)
		child_nodes: [AstNode(left_expr), op_tok, right_expr]
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
	return '$ex.left_expr $ex.op_tok.lit $ex.right_expr'
}

pub struct UnaryExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .unary_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	op_tok       token.Token
	operand_expr Expr
}

// new_binary_expr instance an binary expression 
// with a left_expr side, right_expr side and operator
pub fn new_unary_expr(tree &SyntaxTree, op_tok token.Token, operand_expr Expr) UnaryExpr {
	if !(op_tok.kind in ast.unary_expr_tokens) {
		panic('Expected a unary expresson token, got ($op_tok.kind)')
	}
	return UnaryExpr{
		tree: tree
		op_tok: op_tok
		operand_expr: operand_expr
		pos: source.new_pos_from_pos_bounds(op_tok.pos, operand_expr.pos)
		child_nodes: [AstNode(op_tok), operand_expr]
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
	return '$ex.op_tok.lit$ex.operand_expr'
}

pub struct ParaExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .fn_decl_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	open_para_token  token.Token
	expr             Expr
	close_para_token token.Token
}

pub fn new_paranthesis_expr(tree &SyntaxTree, open_para_token token.Token, expr Expr, close_para_token token.Token) ParaExpr {
	return ParaExpr{
		tree: tree
		open_para_token: open_para_token
		expr: expr
		close_para_token: close_para_token
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
