module ast

import lib.comp.token
import lib.comp.util.source

pub struct ForRangeStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .for_range_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	for_key    token.Token
	name_tok   token.Token
	in_key     token.Token
	range_expr Expr
	body_stmt  Stmt
}

pub fn new_for_range_stmt(tree &SyntaxTree, for_key token.Token, name_tok token.Token, in_key token.Token, range_expr Expr, body_stmt Stmt) ForRangeStmt {
	return ForRangeStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(for_key.pos, body_stmt.pos)
		child_nodes: [AstNode(for_key), name_tok, in_key, range_expr, body_stmt]
		for_key: for_key
		name_tok: name_tok
		in_key: in_key
		range_expr: range_expr
		body_stmt: body_stmt
	}
}

pub fn (e &ForRangeStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ForRangeStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ForRangeStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex ForRangeStmt) str() string {
	return 'for $ex.name_tok.lit in $ex.range_expr $ex.body_stmt'
}

pub struct ForStmt {
pub:
	has_cond bool
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .for_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	for_key   token.Token
	cond_expr Expr
	body_stmt Stmt
}

pub fn (fs &ForStmt) child_nodes() []AstNode {
	return fs.child_nodes
}

pub fn new_for_stmt(tree &SyntaxTree, for_key token.Token, cond_expr Expr, body_stmt Stmt, has_cond bool) ForStmt {
	return ForStmt{
		tree: tree
		for_key: for_key
		cond_expr: cond_expr
		body_stmt: body_stmt
		has_cond: has_cond
		pos: source.new_pos_from_pos_bounds(for_key.pos, body_stmt.pos)
		child_nodes: [AstNode(for_key), cond_expr, body_stmt]
	}
}

pub fn (iss ForStmt) node_str() string {
	return typeof(iss).name
}

pub fn (ex ForStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (iss ForStmt) str() string {
	if iss.has_cond {
		return 'for $iss.cond_expr $iss.body_stmt'
	} else {
		return 'for $iss.body_stmt'
	}
}
