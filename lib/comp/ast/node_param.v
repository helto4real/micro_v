module ast

import lib.comp.token
import lib.comp.util.source

// TypeNode represents a type identifier
// 	parses:
//		ident VarName	
//		mut ident VarName	
//		ident &VarName
pub struct ParamNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .node_param
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	ident  token.Token
	typ    TypeNode
	is_mut bool
}

pub fn new_param_node(tree &SyntaxTree, ident token.Token, typ TypeNode, is_mut bool) ParamNode {
	return ParamNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(ident.pos, typ.ident.pos)
		child_nodes: [AstNode(ident), typ]
		ident: ident
		typ: typ
		is_mut: is_mut
	}
}

pub fn (e &ParamNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ParamNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ParamNode) node_str() string {
	return typeof(ex).name
}
