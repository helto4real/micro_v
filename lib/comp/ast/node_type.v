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
	tree        &SyntaxTree
	kind        SyntaxKind = .type_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	name_expr    NameExpr
	ref_tok      token.Token
	variadic_tok token.Token
	is_ref       bool
	is_void      bool
	is_variadic  bool
}

pub fn new_type_node(tree &SyntaxTree, name_expr NameExpr, variadic_tok token.Token) TypeNode {
	is_void := name_expr.names[0].kind == .void
	is_variadic := variadic_tok.kind != .void

	return TypeNode{
		tree: tree
		pos: name_expr.pos
		child_nodes: [AstNode(Expr(name_expr))]
		name_expr: name_expr
		is_ref: name_expr.is_ref
		is_void: is_void
		is_variadic: is_variadic
	}
}

pub fn (e &TypeNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex TypeNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex TypeNode) node_str() string {
	return typeof(ex).name
}

pub fn (ex &TypeNode) str() string {
	name := ex.name_expr.name_tok.lit
	return name
}