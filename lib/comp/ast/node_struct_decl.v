module ast

import strings
import lib.comp.token
import lib.comp.util.source

pub struct StructDeclNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .node_fn_decl
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	struct_tok  token.Token
	ident    	token.Token
	lcbr_tok	token.Token
	members		[]StructMemberNode
	rcbr_tok	token.Token
}

pub fn new_struct_decl_node(tree &SyntaxTree, struct_tok token.Token, ident token.Token, lcbr_tok	token.Token, members []StructMemberNode, rcbr_tok	token.Token) StructDeclNode {
	mut child_nodes := [AstNode(struct_tok), ident]
	for member in members {
		child_nodes << member
	}
	// child_nodes << rpar_tok
	// child_nodes << typ_node

	return StructDeclNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(struct_tok.pos, ident.pos)
		child_nodes: child_nodes
		struct_tok: struct_tok
		ident: ident
		lcbr_tok: lcbr_tok
		members: members
		rcbr_tok: rcbr_tok
	}
}

pub fn (e &StructDeclNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex StructDeclNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex StructDeclNode) node_str() string {
	return typeof(ex).name
}

pub fn (ex StructDeclNode) str() string {
	mut b := strings.new_builder(0)
	b.writeln('struct $ex.ident.lit {')
	for member in ex.members {
		b.writeln('  $member.ident.lit $member.type_name.lit')
	}
	b.writeln('}')

	return b.str()
}

pub struct StructMemberNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .struct_mbr_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	ident       token.Token
	type_name  	token.Token
	has_init	bool
	init_expr	Expr
}

pub fn new_struct_member_with_init_node(tree &SyntaxTree, ident token.Token, type_name token.Token, init_expr Expr) StructMemberNode {
	mut child_nodes := [AstNode(ident), type_name, init_expr]
	return StructMemberNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(ident.pos, init_expr.pos)
		child_nodes: child_nodes
		ident: ident
		type_name: type_name
		init_expr: init_expr
		has_init: true
	}
}

pub fn new_struct_member_node(tree &SyntaxTree, ident token.Token, type_name token.Token) StructMemberNode {
	mut child_nodes := [AstNode(ident), type_name]
	return StructMemberNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(ident.pos, type_name.pos)
		child_nodes: child_nodes
		ident: ident
		type_name: type_name
		has_init: false
	}
}

pub fn (e &StructMemberNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex StructMemberNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex StructMemberNode) node_str() string {
	return typeof(ex).name
}