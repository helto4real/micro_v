module ast

import lib.comp.token
import lib.comp.util

pub struct VarDeclStmt {
pub:
	kind   SyntaxKind = .var_decl_stmt
	nodes  []AstNode
	is_mut bool

	ident token.Token
	eq    token.Token
	expr  Expr
	pos   util.Pos
}

pub fn new_var_decl_stmt(ident token.Token, eq token.Token, expr Expr, is_mut bool) VarDeclStmt {
	return VarDeclStmt{
		ident: ident
		expr: expr
		eq: eq
		is_mut: is_mut
		pos: util.new_pos_from_pos_bounds(ident.pos, expr.pos())
		nodes: [AstNode(ident), eq, expr]
	}
}

pub fn (ae &VarDeclStmt) child_nodes() []AstNode {
	return ae.nodes
}

pub fn (ex &VarDeclStmt) node_str() string {
	return typeof(ex).name
}
