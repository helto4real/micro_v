module ast

import lib.comp.util.source
import lib.comp.token

pub struct ReturnStmt {
pub:
	// general ast node
	kind        SyntaxKind = .return_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	has_expr   bool
	return_tok token.Token
	expr       Expr
}

pub fn new_return_with_expr_stmt(return_tok token.Token, expr Expr) ReturnStmt {
	return ReturnStmt{
		pos: return_tok.pos
		child_nodes: [AstNode(return_tok), expr]
		return_tok: return_tok
		expr: expr
		has_expr: true
	}
}

pub fn new_return_stmt(return_tok token.Token) ReturnStmt {
	return ReturnStmt{
		pos: return_tok.pos
		child_nodes: [AstNode(return_tok)]
		return_tok: return_tok
		has_expr: false
	}
}

pub fn (e &ReturnStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ReturnStmt) node_str() string {
	return typeof(ex).name
}
