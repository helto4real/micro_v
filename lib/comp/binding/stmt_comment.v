module binding

import lib.comp.token

pub struct BoundCommentStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .comment_stmt
	child_nodes []BoundNode
	// child nodes
	comment string
}

pub fn new_bound_comment_stmt(comment_tok token.Token) BoundStmt {
	return BoundCommentStmt{
		comment: comment_tok.lit
	}
}

pub fn (ex BoundCommentStmt) node_str() string {
	return typeof(ex).name
}
