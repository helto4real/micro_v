module ast

import lib.comp.token
import lib.comp.util.source

pub struct StructInitExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .struct_init_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	name_expr  NameExpr
	lcbr_tok token.Token
	members  []StructInitMemberNode
	rcbr_tok token.Token
}

pub fn new_struct_init_expr(tree &SyntaxTree, name_expr NameExpr, lcbr_tok token.Token, members []StructInitMemberNode, rcbr_tok token.Token) StructInitExpr {
	mut child_nodes := [AstNode(Expr(name_expr)), lcbr_tok]
	for member in members {
		child_nodes << member
	}
	child_nodes << rcbr_tok
	return StructInitExpr{
		tree: tree
		name_expr: name_expr
		members: members
		lcbr_tok: lcbr_tok
		pos: source.new_pos_from_pos_bounds(name_expr.name_tok.pos, lcbr_tok.pos)
		child_nodes: child_nodes
	}
}

pub fn new_struct_init_no_members_expr(type_name string) StructInitExpr {
	name_toks := [token.Token {
			kind: .name
			lit: type_name
			source: &source.SourceText(0)
		}]
	
	name_expr := new_name_expr(&SyntaxTree(0), name_toks, false)
	return StructInitExpr{
		tree: &SyntaxTree(0)
		name_expr: name_expr
		// members: members
		// lcbr_tok: lcbr_tok
		// pos: source.new_pos_from_pos_bounds(typ_tok.pos, lcbr_tok.pos)
		// child_nodes: child_nodes
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
	ident token.Token
	colon token.Token
	expr  Expr
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
