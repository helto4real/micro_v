module ast

import lib.comp.util
import lib.comp.token

pub struct ContinueStmt {
pub:
	// general ast node
	kind        SyntaxKind = .cont_stmt
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	cont_tok token.Token
}

pub fn new_continue_stmt(cont_tok token.Token) ContinueStmt {
	return ContinueStmt{
		pos: cont_tok.pos
		child_nodes: [AstNode(cont_tok)]
		cont_tok: cont_tok
	}
}

pub fn (e &ContinueStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &ContinueStmt) node_str() string {
	return typeof(ex).name
}
