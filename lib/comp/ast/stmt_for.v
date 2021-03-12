module ast

import lib.comp.token
import lib.comp.util

pub struct ForRangeStmt {
pub:
	// general ast node
	kind        SyntaxKind = .for_range_stmt
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	key_for    token.Token
	ident      token.Token
	key_in     token.Token
	range_expr Expr
	body_stmt  Stmt
}

pub fn new_for_range_stmt(key_for token.Token, ident token.Token, key_in token.Token, range_expr Expr, body_stmt Stmt) ForRangeStmt {
	return ForRangeStmt{
		pos: util.new_pos_from_pos_bounds(key_for.pos, body_stmt.pos)
		child_nodes: [AstNode(key_for), ident, key_in, range_expr, body_stmt]
		key_for: key_for
		ident: ident
		key_in: key_in
		range_expr: range_expr
		body_stmt: body_stmt
	}
}

pub fn (e &ForRangeStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &ForRangeStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex ForRangeStmt) str() string {
	return 'for $ex.ident.lit in $ex.range_expr $ex.body_stmt'
}

pub struct ForStmt {
pub:
	// Node
	kind        SyntaxKind = .for_stmt
	child_nodes []AstNode
	pos         util.Pos
	has_cond    bool

	key_for   token.Token
	cond_expr Expr
	body_stmt Stmt
}

pub fn (fs &ForStmt) child_nodes() []AstNode {
	return fs.child_nodes
}

pub fn new_for_stmt(key_for token.Token, cond_expr Expr, body_stmt Stmt, has_cond bool) ForStmt {
	return ForStmt{
		key_for: key_for
		cond_expr: cond_expr
		body_stmt: body_stmt
		has_cond: has_cond
		pos: util.new_pos_from_pos_bounds(key_for.pos, body_stmt.pos)
		child_nodes: [AstNode(key_for), cond_expr, body_stmt]
	}
}

pub fn (iss &ForStmt) node_str() string {
	return typeof(iss).name
}

pub fn (iss ForStmt) str() string {
	if iss.has_cond {
		return 'for $iss.cond_expr $iss.body_stmt'
	} else {
		return 'for $iss.body_stmt'
	}
}
