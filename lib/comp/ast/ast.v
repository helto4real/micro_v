module ast

import lib.comp.token
import lib.comp.util

pub struct CompNode {
pub:
	kind        SyntaxKind = .comp_node
	eof_tok     token.Token
	pos         util.Pos
	stmt        Stmt
	child_nodes []AstNode
}

pub fn new_comp_expr(stmt Stmt, eof_tok token.Token) CompNode {
	return CompNode{
		pos: stmt.pos()
		stmt: stmt
		eof_tok: eof_tok
		child_nodes: [AstNode(stmt)]
	}
}
pub fn (cn &CompNode) child_nodes() []AstNode {
	return cn.child_nodes
}
