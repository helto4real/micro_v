module ast

import lib.comp.util
import lib.comp.token

pub struct CommentStmt {
pub:
	// general ast node
	kind        SyntaxKind = .comment_stmt
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	comment_tok token.Token
}

pub fn new_comment_stmt(comment_tok token.Token) CommentStmt {
	return CommentStmt{
		pos: comment_tok.pos
		child_nodes: [AstNode(comment_tok)]
		comment_tok: comment_tok
	}
}

pub fn (e &CommentStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &CommentStmt) node_str() string {
	return typeof(ex).name
}
