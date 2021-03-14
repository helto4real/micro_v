module ast

import lib.comp.util.source

pub struct GlobStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .global_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	stmt Stmt
}

pub fn new_glob_stmt(tree &SyntaxTree, stmt Stmt) GlobStmt {
	return GlobStmt{
		tree: tree
		pos: stmt.pos
		child_nodes: [AstNode(stmt)]
		stmt: stmt
	}
}

pub fn (e &GlobStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex GlobStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex GlobStmt) node_str() string {
	return typeof(ex).name
}
