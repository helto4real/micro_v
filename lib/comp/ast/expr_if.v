module ast

import lib.comp.token
import lib.comp.util.source

// Support if expression syntax
//	x := if i < 100 {10} else {20}
pub struct IfExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .if_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	key_if    token.Token
	key_else  token.Token
	cond_expr Expr
	then_stmt Stmt
	else_stmt Stmt
}

pub fn new_if_expr(tree &SyntaxTree, key_if token.Token, cond_expr Expr, then_stmt Stmt, key_else token.Token, else_stmt Stmt) IfExpr {
	return IfExpr{
		tree: tree
		key_if: key_if
		key_else: key_else
		cond_expr: cond_expr
		then_stmt: then_stmt
		else_stmt: else_stmt
		pos: source.new_pos_from_pos_bounds(key_if.pos, else_stmt.pos)
		child_nodes: [AstNode(key_if), cond_expr, then_stmt, key_else, else_stmt]
	}
}

pub fn (iss &IfExpr) child_nodes() []AstNode {
	return iss.child_nodes
}

pub fn (ex IfExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex IfExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex IfExpr) str() string {
	return 'if $ex.cond_expr {}'
}
