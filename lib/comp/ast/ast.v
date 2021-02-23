module ast

import lib.comp.token
import lib.comp.util

pub struct CompExpr {
pub:
	kind        SyntaxKind = .comp_node
	eof_tok     token.Token
	pos         util.Pos
	stmt        Stmt
	child_nodes []AstNode
}

pub fn new_comp_expr(stmt Stmt, eof_tok token.Token) CompExpr {
	return CompExpr{
		pos: stmt.pos()
		stmt: stmt
		eof_tok: eof_tok
		child_nodes: [AstNode(stmt)]
	}
}
pub fn (cn &CompExpr) child_nodes() []AstNode {
	return cn.child_nodes
}
