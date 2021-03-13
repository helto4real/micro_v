module ast

import lib.comp.util.source

pub struct GlobStmt {
pub:
	// general ast node
	kind        SyntaxKind = .global_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	stmt Stmt
}

pub fn new_glob_stmt(stmt Stmt) GlobStmt {
	return GlobStmt{
		pos: stmt.pos
		child_nodes: [AstNode(stmt)]
		stmt: stmt
	}
}

pub fn (e &GlobStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex GlobStmt) node_str() string {
	return typeof(ex).name
}
