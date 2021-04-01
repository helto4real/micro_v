module ast

import lib.comp.token
import lib.comp.util.source

// TypeNode represents a type identifier
// 	parses:
//		VarName	
//		&VarName
pub struct TypeNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .type_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	name_tok token.Token
	is_ref   bool
	is_void  bool
}

pub fn new_type_node(tree &SyntaxTree, name_tok token.Token, is_ref bool, is_void bool) TypeNode {
	return TypeNode{
		tree: tree
		pos: name_tok.pos
		child_nodes: [AstNode(name_tok)]
		name_tok: name_tok
		is_ref: is_ref
		is_void: is_void
	}
}

pub fn (e &TypeNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex TypeNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex TypeNode) node_str() string {
	return typeof(ex).name
}
