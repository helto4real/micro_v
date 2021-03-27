module ast

import lib.comp.token
import lib.comp.util.source

pub struct AssignExpr {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .assign_expr
	child_nodes []AstNode

	ident  NameExpr
	eq_tok token.Token
	expr   Expr
	pos    source.Pos
}

pub fn new_assign_expr(tree &SyntaxTree, ident NameExpr, eq_tok token.Token, expr Expr) AssignExpr {
	return AssignExpr{
		tree: tree
		ident: ident
		expr: expr
		eq_tok: eq_tok
		pos: source.new_pos_from_pos_bounds(ident.pos, expr.pos)
		child_nodes: [AstNode(Expr(ident)), eq_tok, expr]
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
