module ast

import lib.comp.token
import lib.comp.util

pub struct ForRangeStmt {
pub:
	// Node
	kind        SyntaxKind = .for_range_stmt
	child_nodes []AstNode
	pos         util.Pos

	key_for_tok token.Token
	ident_tok   token.Token
	key_in_tok  token.Token
	range       Expr
	body        Stmt
}

pub fn new_for_range_stmt(key_for_tok token.Token, ident_tok token.Token, key_in_tok token.Token, range Expr, body Stmt) ForRangeStmt {
	return ForRangeStmt{
		key_for_tok: key_for_tok
		ident_tok: ident_tok
		key_in_tok: key_in_tok
		range: range
		body: body
		pos: util.new_pos_from_pos_bounds(key_for_tok.pos, body.pos())
		child_nodes: [AstNode(key_for_tok), ident_tok, key_in_tok, range, body]
	}
}

pub fn (fr &ForRangeStmt) child_nodes() []AstNode {
	return fr.child_nodes
}

pub struct ForStmt {
pub:
	// Node
	kind        SyntaxKind = .for_stmt
	child_nodes []AstNode
	pos         util.Pos
	has_cond    bool

	key_for_tok token.Token
	cond        Expr
	body        Stmt
}

pub fn (fs &ForStmt) child_nodes() []AstNode {
	return fs.child_nodes
}

pub fn new_for_stmt(key_for_tok token.Token, cond Expr, body Stmt, has_cond bool) ForStmt {
	return ForStmt{
		key_for_tok: key_for_tok
		cond: cond
		body: body
		has_cond: has_cond
	}
}
