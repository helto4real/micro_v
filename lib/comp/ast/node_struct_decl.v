module ast

import strings
import lib.comp.token
import lib.comp.util.source

pub struct StructDeclNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .struct_decl_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	struct_tok token.Token
	name_expr  NameExpr
	lcbr_tok   token.Token
	members    []StructMemberNode
	rcbr_tok   token.Token

	is_c_decl bool
}

pub fn new_struct_decl_node(tree &SyntaxTree, struct_tok token.Token, name_expr NameExpr, lcbr_tok token.Token, members []StructMemberNode, rcbr_tok token.Token) StructDeclNode {
	mut child_nodes := [AstNode(struct_tok), Expr(name_expr)]
	for member in members {
		child_nodes << member
	}

	return StructDeclNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(struct_tok.pos, name_expr.pos)
		child_nodes: child_nodes
		struct_tok: struct_tok
		name_expr: name_expr
		lcbr_tok: lcbr_tok
		members: members
		rcbr_tok: rcbr_tok
		is_c_decl: name_expr.names.len > 1 && name_expr.names[0].lit == 'C'
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
	b.writeln('struct $ex.name_expr.name_tok.lit {')
	for member in ex.members {
		b.writeln('  $member.name_tok.lit $member.type_expr.name_tok.lit')
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
	name_tok  token.Token
	ref_tok   token.Token
	type_expr NameExpr
	is_ref    bool
	has_init  bool
	init_expr Expr
}

pub fn new_struct_member_with_init_node(tree &SyntaxTree, name_tok token.Token, ref_tok token.Token, type_expr NameExpr, init_expr Expr) StructMemberNode {
	is_ref := ref_tok.kind == .amp
	mut child_nodes := [AstNode(name_tok), Expr(type_expr), init_expr]
	return StructMemberNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(name_tok.pos, init_expr.pos)
		child_nodes: child_nodes
		name_tok: name_tok
		ref_tok: ref_tok
		type_expr: type_expr
		init_expr: init_expr
		is_ref: is_ref
		has_init: true
	}
}

pub fn new_struct_member_node(tree &SyntaxTree, name_tok token.Token, ref_tok token.Token, type_expr NameExpr) StructMemberNode {
	is_ref := ref_tok.kind == .amp
	mut child_nodes := [AstNode(name_tok), Expr(type_expr)]
	return StructMemberNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(name_tok.pos, type_expr.pos)
		child_nodes: child_nodes
		name_tok: name_tok
		ref_tok: ref_tok
		type_expr: type_expr
		is_ref: is_ref
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

pub fn (ex StructMemberNode) str() string {
	return 'StructMemberNode'
}
