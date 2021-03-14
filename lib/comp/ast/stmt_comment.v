module ast

import lib.comp.util.source
import lib.comp.token

pub struct CommentStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .comment_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	comment_tok token.Token
}

pub fn new_comment_stmt(tree &SyntaxTree, comment_tok token.Token) CommentStmt {
	return CommentStmt{
		tree: tree
		pos: comment_tok.pos
		child_nodes: [AstNode(comment_tok)]
		comment_tok: comment_tok
	}
}

pub fn (e &CommentStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex CommentStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex CommentStmt) node_str() string {
	return typeof(ex).name
}
