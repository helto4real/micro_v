module ast

import lib.comp.token
import lib.comp.util.source

pub struct FnDeclNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .fn_decl_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	fn_key   token.Token
	name_tok token.Token
	lpar_tok token.Token
	params   SeparatedSyntaxList
	rpar_tok token.Token
	typ_node TypeNode

	block BlockStmt
}

pub fn new_empty_fn_decl_node(tree &SyntaxTree) FnDeclNode {
	return FnDeclNode{
		tree: tree
	}
}

pub fn new_fn_decl_node(tree &SyntaxTree, fn_key token.Token, name_tok token.Token, lpar_tok token.Token, params SeparatedSyntaxList, rpar_tok token.Token, typ_node TypeNode, block BlockStmt) FnDeclNode {
	mut child_nodes := [AstNode(fn_key), name_tok, lpar_tok]
	for i := 0; i < params.len(); i++ {
		child_nodes << params.at(i)
	}
	child_nodes << rpar_tok
	child_nodes << typ_node

	return FnDeclNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(fn_key.pos, block.pos)
		child_nodes: child_nodes
		fn_key: fn_key
		name_tok: name_tok
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
		typ_node: typ_node
		block: block
	}
}

pub fn (e &FnDeclNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex FnDeclNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex FnDeclNode) node_str() string {
	return typeof(ex).name
}
