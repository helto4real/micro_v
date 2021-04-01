module ast

import lib.comp.token
import lib.comp.util.source

pub struct VarDeclStmt {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .var_decl_stmt
	child_nodes []AstNode
	is_mut      bool

	ident  NameExpr
	eq_tok token.Token
	expr   Expr
	pos    source.Pos
}

pub fn new_var_decl_stmt(tree &SyntaxTree, ident NameExpr, eq_tok token.Token, expr Expr, is_mut bool) VarDeclStmt {
	return VarDeclStmt{
		tree: tree
		ident: ident
		expr: expr
		eq_tok: eq_tok
		is_mut: is_mut
		pos: source.new_pos_from_pos_bounds(ident.name_tok.pos, expr.pos)
		child_nodes: [AstNode(ident.name_tok), eq_tok, expr]
	}
}

pub fn (ae &VarDeclStmt) child_nodes() []AstNode {
	return ae.child_nodes
}

pub fn (ex VarDeclStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex VarDeclStmt) node_str() string {
	return typeof(ex).name
}
