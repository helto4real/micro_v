module ast

import lib.comp.util.source
import lib.comp.token

pub struct BreakStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .break_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	break_key token.Token
}

pub fn new_break_stmt(tree &SyntaxTree, break_key token.Token) BreakStmt {
	return BreakStmt{
		tree: tree
		pos: break_key.pos
		child_nodes: [AstNode(break_key)]
		break_key: break_key
	}
}

pub fn (e &BreakStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex BreakStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex BreakStmt) node_str() string {
	return typeof(ex).name
}
