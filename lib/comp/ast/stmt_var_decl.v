module ast

import lib.comp.token
import lib.comp.util

pub struct VarDeclStmtSyntax {
pub:
	kind   SyntaxKind = .var_decl_stmt
	nodes []AstNode
	is_mut bool

	ident  token.Token
	eq_tok token.Token
	expr   ExpressionSyntax
	pos    util.Pos
}

pub fn new_var_decl_stmt(ident token.Token, eq_tok token.Token, expr ExpressionSyntax, is_mut bool) VarDeclStmtSyntax {
	return VarDeclStmtSyntax{
		ident: ident
		expr: expr
		eq_tok: eq_tok
		is_mut: is_mut
		pos: util.new_pos_from_pos_bounds(ident.pos, expr.pos())
		nodes: [AstNode(ident), eq_tok, expr]
	}
}

pub fn (ae &VarDeclStmtSyntax) child_nodes() []AstNode {
	return ae.nodes
}
