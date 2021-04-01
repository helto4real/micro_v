module ast

import lib.comp.util.source
import lib.comp.token

pub struct ContinueStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .continue_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	cont_key token.Token
}

pub fn new_continue_stmt(tree &SyntaxTree, cont_key token.Token) ContinueStmt {
	return ContinueStmt{
		tree: tree
		pos: cont_key.pos
		child_nodes: [AstNode(cont_key)]
		cont_key: cont_key
	}
}

pub fn (e &ContinueStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ContinueStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ContinueStmt) node_str() string {
	return typeof(ex).name
}
