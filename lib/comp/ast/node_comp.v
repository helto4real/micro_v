module ast

import lib.comp.token
import lib.comp.util.source

pub struct CompNode {
pub:
	kind        SyntaxKind = .comp_node
	eof_tok     token.Token
	pos         source.Pos
	child_nodes []AstNode
pub mut:
	tree    &SyntaxTree
	members []MemberNode
}

// // TODO: fix child_nodes and pos
// //pub fn new_comp_expr(tree &SyntaxTree, members []MemberNode, eof_tok token.Token) CompNode {
// pub fn new_comp_expr(members []MemberNode, eof_tok token.Token) CompNode {
// 	if members.len == 0 {
// 		return CompNode{} //tree:tree
// 	}
// 	first := members.first()
// 	return CompNode{
// 		// tree: tree
// 		pos: source.new_pos_from_pos_bounds(first.pos, eof_tok.pos)
// 		members: members
// 		eof_tok: eof_tok
// 		child_nodes: members.map(AstNode(it))
// 	}
// }

pub fn (cn &CompNode) child_nodes() []AstNode {
	return cn.child_nodes
}

pub fn (ex CompNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex CompNode) node_str() string {
	return typeof(ex).name
}
