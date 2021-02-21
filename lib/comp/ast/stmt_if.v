module ast

import lib.comp.token
import lib.comp.util

pub struct IfStmtSyntax {
pub:
	kind   SyntaxKind = .if_stmt
	pos    util.Pos
	nodes  []AstNode

	key_if_tok  token.Token
	cond   ExpressionSyntax
	block_stmt  StatementSyntax
	else_clause ElseClauseSyntax
}

pub fn new_if_stmt(key_if_tok token.Token, cond ExpressionSyntax, block_stmt StatementSyntax, else_clause ElseClauseSyntax) IfStmtSyntax {
	return IfStmtSyntax{
		key_if_tok: key_if_tok
		cond: cond
		block_stmt: block_stmt
		else_clause: else_clause
		pos: util.new_pos_from_pos_bounds(key_if_tok.pos, block_stmt.pos())
		nodes: [AstNode(key_if_tok), cond, block_stmt, else_clause]
	}
}

pub fn (iss &IfStmtSyntax) child_nodes() []AstNode {
	return iss.nodes
}


pub struct ElseClauseSyntax {
pub:
	kind   SyntaxKind = .else_node
	pos    util.Pos
	nodes  []AstNode

	key_else_tok  token.Token
	block_stmt  StatementSyntax
	is_defined bool
}

pub fn new_else_clause_node(key_else_tok token.Token, block_stmt StatementSyntax) ElseClauseSyntax {
	return ElseClauseSyntax{
		key_else_tok: key_else_tok
		block_stmt: block_stmt
		pos: util.new_pos_from_pos_bounds(key_else_tok.pos, block_stmt.pos())
		nodes: [AstNode(key_else_tok), block_stmt]
		is_defined: true
	}
}

pub fn new_empty_else_clause_node() ElseClauseSyntax {
	return ElseClauseSyntax{
		is_defined: false
	}
}

pub fn (ecs &ElseClauseSyntax) child_nodes() []AstNode {
	return ecs.nodes
}

pub fn (ecs &ElseClauseSyntax) pos() util.Pos {
	return ecs.pos
}