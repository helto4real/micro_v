module ast

import lib.comp.token
import lib.comp.util.source

pub struct AssignExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .assign_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	name_expr NameExpr
	eq_tok    token.Token
	expr      Expr
}

pub fn new_assign_expr(tree &SyntaxTree, name_expr NameExpr, eq_tok token.Token, expr Expr) AssignExpr {
	return AssignExpr{
		tree: tree
		name_expr: name_expr
		expr: expr
		eq_tok: eq_tok
		pos: source.new_pos_from_pos_bounds(name_expr.pos, expr.pos)
		child_nodes: [AstNode(Expr(name_expr)), eq_tok, expr]
	}
}

pub fn (ae &AssignExpr) child_nodes() []AstNode {
	return ae.child_nodes
}

pub fn (ex AssignExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex AssignExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex AssignExpr) str() string {
	return '${ex.name_expr.name_tok.lit} = $ex.expr'
}
