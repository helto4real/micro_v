module ast

import lib.comp.token
import lib.comp.util

pub struct BlockStmt {
pub:
	// Node
	kind              SyntaxKind = .block_stmt
	child_nodes       []AstNode
	pos               util.Pos
	open_brc  token.Token
	stmts        []Stmt
	close_brc token.Token
}

pub fn new_block_stmt(open_brc token.Token, stmts []Stmt, close_brc token.Token) BlockStmt {
	mut child_nodes := [AstNode(open_brc)]
	child_nodes.insert(0,stmts.map(AstNode(it)))
	child_nodes << close_brc
	return BlockStmt{
		open_brc: open_brc
		stmts: stmts
		close_brc: close_brc
		child_nodes: child_nodes
	}
}

pub fn (bs &BlockStmt) child_nodes() []AstNode {
	return bs.child_nodes
}
