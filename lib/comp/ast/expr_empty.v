module ast

import lib.comp.util.source

pub struct EmptyExpr {
pub:
	// general ast node
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

pub fn (ex EmptyExpr) node_str() string {
	return typeof(ex).name
}
