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
	kind        SyntaxKind = .node_type
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	ident   token.Token
	is_ref  bool
	is_void bool
}

pub fn new_type_node(ident token.Token, is_ref bool, is_void bool) TypeNode {
	return TypeNode{
		pos: ident.pos
		child_nodes: [AstNode(ident)]
		ident: ident
		is_ref: is_ref
		is_void: is_void
	}
}

pub fn (e &TypeNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex TypeNode) node_str() string {
	return typeof(ex).name
}
