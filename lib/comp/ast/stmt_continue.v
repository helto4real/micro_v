module ast

import lib.comp.util.source
import lib.comp.token

pub struct ContinueStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .cont_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	cont_tok token.Token
}

pub fn new_continue_stmt(tree &SyntaxTree, cont_tok token.Token) ContinueStmt {
	return ContinueStmt{
		tree: tree
		pos: cont_tok.pos
		child_nodes: [AstNode(cont_tok)]
		cont_tok: cont_tok
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
