module ast

import lib.comp.util.source
import lib.comp.token

pub struct BreakStmt {
pub:
	// general ast node
	kind        SyntaxKind = .break_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	break_tok token.Token
}

pub fn new_break_stmt(break_tok token.Token) BreakStmt {
	return BreakStmt{
		pos: break_tok.pos
		child_nodes: [AstNode(break_tok)]
		break_tok: break_tok
	}
}

pub fn (e &BreakStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex BreakStmt) node_str() string {
	return typeof(ex).name
}
