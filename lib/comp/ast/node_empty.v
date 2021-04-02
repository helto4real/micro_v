module ast

import lib.comp.util.source

pub struct EmptyNode {
pub:
	// general ast node
	kind        SyntaxKind = .comp_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
pub mut:
	tree    &SyntaxTree = 0
	members []MemberNode
}

pub fn new_empty_node() EmptyNode {
	return EmptyNode{}
}

pub fn (cn &EmptyNode) child_nodes() []AstNode {
	return cn.child_nodes
}

pub fn (ex EmptyNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex EmptyNode) node_str() string {
	return typeof(ex).name
}
