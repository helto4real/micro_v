module ast

import lib.comp.token
import lib.comp.util.source

// TypeNode represents a type identifier
// 	parses:
//		name_tok VarName	
//		mut name_tok VarName	
//		name_tok &VarName
pub struct ParamNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .param_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	name_tok token.Token
	typ      TypeNode
	is_mut   bool
}

pub fn new_param_node(tree &SyntaxTree, name_tok token.Token, typ TypeNode, is_mut bool) ParamNode {
	return ParamNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(name_tok.pos, typ.name_tok.pos)
		child_nodes: [AstNode(name_tok), typ]
		name_tok: name_tok
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
