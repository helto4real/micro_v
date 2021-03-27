module ast

import lib.comp.token
import lib.comp.util.source

pub struct StructInitExpr {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .struct_init_expr
	pos         source.Pos
	child_nodes []AstNode

	typ_token   token.Token
	lcbr_token 	token.Token
	members 	[]StructInitMemberNode
	rcbr_token 	token.Token
}

pub fn new_struct_init_expr(tree &SyntaxTree, typ_token   token.Token, lcbr_token 	token.Token, members []StructInitMemberNode, rcbr_token 	token.Token) StructInitExpr {
	mut child_nodes := [AstNode(typ_token), lcbr_token]
	for member in members {
		child_nodes << member
	}
	child_nodes << rcbr_token
	return StructInitExpr{
		tree: tree
		typ_token: typ_token
		members: members
		lcbr_token: lcbr_token
		pos: source.new_pos_from_pos_bounds(typ_token.pos, lcbr_token.pos)
		child_nodes: child_nodes
	}
}

pub fn (iss &StructInitExpr) child_nodes() []AstNode {
	return iss.child_nodes
}

pub fn (ex StructInitExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex StructInitExpr) node_str() string {
	return typeof(ex).name
}


pub struct StructInitMemberNode {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .struct_init_mbr_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	ident       token.Token
	colon		token.Token
	expr	  	Expr
}

pub fn new_init_struct_member_node(tree &SyntaxTree, ident token.Token, colon token.Token, expr Expr) StructInitMemberNode {
	return StructInitMemberNode{
		tree: tree
		pos: source.new_pos_from_pos_bounds(ident.pos, expr.pos)
		child_nodes: [AstNode(ident), colon, expr]
		ident: ident
		colon: colon
		expr: expr
	}
}

pub fn (e &StructInitMemberNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex StructInitMemberNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex StructInitMemberNode) node_str() string {
	return typeof(ex).name
}