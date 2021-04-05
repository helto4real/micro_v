module ast

import lib.comp.token
import lib.comp.util.source

pub struct IndexExpr {
pub:
	// general ast node
	tree        &SyntaxTree = &SyntaxTree(0)
	kind        SyntaxKind  = .index_expr
	pos         source.Pos
	child_nodes []AstNode

	left_expr Expr

	lsbr token.Token
	index_expr Expr
	rsbr token.Token
}

pub fn new_index_expr(tree &SyntaxTree, left_expr Expr, lsbr token.Token, index_expr Expr, rsbr token.Token) IndexExpr {
	return IndexExpr{
		tree: tree 
		left_expr: left_expr
		lsbr: lsbr
		index_expr: index_expr
		rsbr: rsbr
		pos: source.new_pos_from_pos_bounds(lsbr.pos, rsbr.pos)
		child_nodes: [AstNode(left_expr), lsbr, index_expr, rsbr]
	}
}

pub fn (ex &IndexExpr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex IndexExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex IndexExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex IndexExpr) str() string {
	return '${ex.left_expr}[$ex.index_expr]'
}