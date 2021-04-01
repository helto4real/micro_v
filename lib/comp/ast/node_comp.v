module ast

import lib.comp.token
import lib.comp.util.source

pub struct CompNode {
pub:
	// general ast node
	kind        SyntaxKind = .comp_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	eof_tok     token.Token
pub mut:
	tree    &SyntaxTree
	members []MemberNode
}

pub fn (cn &CompNode) child_nodes() []AstNode {
	return cn.members.map(AstNode(it))
}

pub fn (ex CompNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex CompNode) node_str() string {
	return typeof(ex).name
}
