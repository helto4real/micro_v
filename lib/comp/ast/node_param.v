module ast

import lib.comp.token
import lib.comp.util

// TypeNode represents a type identifier
// 	parses:
//		ident VarName	
//		mut ident VarName	
//		ident &VarName
pub struct ParamNode {
pub:
	// general ast node
	kind        SyntaxKind = .node_param
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	ident  token.Token
	typ TypeNode
	is_mut bool
}

pub fn new_param_node(ident token.Token, typ TypeNode, is_mut bool) ParamNode {
	return ParamNode{
		pos: util.new_pos_from_pos_bounds(ident.pos, typ.ident.pos)
		child_nodes: [AstNode(ident), typ]
		ident: ident
		typ:typ
		is_mut: is_mut
	}
}
pub fn (e &ParamNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &ParamNode) node_str() string {
	return typeof(ex).name
}
