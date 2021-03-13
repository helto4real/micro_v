module ast

import lib.comp.token
import lib.comp.util.source

pub struct IfStmt {
pub:
	kind         SyntaxKind = .if_stmt
	pos          source.Pos
	child_nodes  []AstNode
	has_else     bool
	key_if_tok   token.Token
	key_else_tok token.Token
	cond_expr    Expr
	then_stmt    Stmt
	else_stmt    Stmt
}

pub fn new_if_else_stmt(key_if_tok token.Token, cond_expr Expr, then_stmt Stmt, key_else_tok token.Token, else_stmt Stmt) IfStmt {
	return IfStmt{
		key_if_tok: key_if_tok
		key_else_tok: key_else_tok
		cond_expr: cond_expr
		has_else: true
		then_stmt: then_stmt
		else_stmt: else_stmt
		pos: source.new_pos_from_pos_bounds(key_if_tok.pos, else_stmt.pos)
		child_nodes: [AstNode(key_if_tok), cond_expr, then_stmt, key_else_tok, else_stmt]
	}
}

pub fn new_if_stmt(key_if_tok token.Token, cond_expr Expr, then_stmt Stmt) IfStmt {
	return IfStmt{
		key_if_tok: key_if_tok
		cond_expr: cond_expr
		has_else: false
		then_stmt: then_stmt
		pos: source.new_pos_from_pos_bounds(key_if_tok.pos, then_stmt.pos)
		child_nodes: [AstNode(key_if_tok), cond_expr, then_stmt]
	}
}

pub fn (iss &IfStmt) child_nodes() []AstNode {
	return iss.child_nodes
}

pub fn (iss IfStmt) node_str() string {
	return typeof(iss).name
}
