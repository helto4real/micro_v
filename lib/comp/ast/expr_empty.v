module ast

import lib.comp.util.source

pub struct EmptyExpr {
pub:
	// general ast node
	tree        &SyntaxTree = &SyntaxTree(0)
	kind        SyntaxKind = .break_stmt
	pos         source.Pos
	child_nodes []AstNode
}

pub fn new_empty_stmt() EmptyExpr {
	return EmptyExpr{}
}

pub fn (ex &EmptyExpr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex EmptyExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex EmptyExpr) node_str() string {
	return typeof(ex).name
}
