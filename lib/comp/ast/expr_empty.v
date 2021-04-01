module ast

import lib.comp.util.source

pub struct NoneExpr {
pub:
	// general ast node
	tree        &SyntaxTree = &SyntaxTree(0)
	kind        SyntaxKind  = .empty_expr
	pos         source.Pos
	child_nodes []AstNode
}

pub fn new_empty_expr() NoneExpr {
	return NoneExpr{}
}

pub fn (ex &NoneExpr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex NoneExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex NoneExpr) node_str() string {
	return typeof(ex).name
}
