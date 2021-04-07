module ast

import lib.comp.token
import lib.comp.util.source

// ReceiverNode represents a type identifier
// 	parses:
//		VarName	
//		&VarName
pub struct ReceiverNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .type_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	lpar_tok token.Token
	mut_tok token.Token
	name_tok token.Token
	typ_node TypeNode
	rpar_tok token.Token
	is_ref       bool
	is_empty bool
	is_mut bool
}

pub fn new_empty_receiver_node() ReceiverNode {
	return ReceiverNode{tree:&SyntaxTree(0), is_empty: true}
}

pub fn new_receiver_node(tree &SyntaxTree, lpar_tok token.Token, mut_tok token.Token, name_tok token.Token, typ_node TypeNode, rpar_tok token.Token) ReceiverNode {
	is_mut := mut_tok.kind == .key_mut
	is_ref := typ_node.is_ref || is_mut
	return ReceiverNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(lpar_tok.pos, rpar_tok.pos)
		child_nodes: [AstNode(lpar_tok), name_tok, typ_node, rpar_tok]
		name_tok: name_tok
		typ_node: typ_node
		is_ref: is_ref
		is_empty: false
		is_mut: is_mut
	}
}

pub fn (e &ReceiverNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ReceiverNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ReceiverNode) node_str() string {
	return typeof(ex).name
}

pub fn (ex &ReceiverNode) str() string {
	return '$ex.name_tok.lit $ex.typ_node.name_tok.lit'
}