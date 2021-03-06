module ast

import lib.comp.token
import lib.comp.util

pub struct FnDeclNode {
pub:
	// general ast node
	kind        SyntaxKind = .node_fn_decl
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	fn_key token.Token
	ident token.Token
	lpar_tok token.Token
	params SeparatedSyntaxList
	rpar_tok token.Token
	typ_node TypeNode

	block BlockStmt
}
pub fn new_empty_fn_decl_node() FnDeclNode {
	return FnDeclNode{
	}
}
pub fn new_fn_decl_node(fn_key token.Token, ident token.Token, lpar_tok token.Token,
					params SeparatedSyntaxList, rpar_tok token.Token, typ_node TypeNode, block BlockStmt) FnDeclNode {
	mut child_nodes := [AstNode(fn_key), ident, lpar_tok]
	for i := 0; i < params.len(); i++ {
		child_nodes << params.at(i)
	}
	child_nodes << rpar_tok
	child_nodes << typ_node

	return FnDeclNode{
		pos: util.new_pos_from_pos_bounds(fn_key.pos, block.pos)
		child_nodes: child_nodes
		fn_key: fn_key
		ident:ident
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
		typ_node:typ_node
		block: block
	}
}
pub fn (e &FnDeclNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &FnDeclNode) node_str() string {
	return typeof(ex).name
}
