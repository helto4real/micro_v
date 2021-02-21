module ast

import lib.comp.token
import lib.comp.util

pub fn (e &ExpressionSyntax) kind() SyntaxKind {
	match e {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, EmptyExpr, NameExpr, AssignExpr, ComplationSyntax
		{
			return e.kind
		}
	}
}

// Nodes in syntax tree
pub type AstNode = ExpressionSyntax | StatementSyntax | token.Token

pub fn (ex &ExpressionSyntax) children() []AstNode {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr, ComplationSyntax
		{
			return ex.child_nodes()
		}
	}
}

pub fn (ex &ExpressionSyntax) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr, ComplationSyntax
		{
			return ex.pos
		}
	}
}

pub fn (ex &AstNode) pos() util.Pos {
	match ex {
		ExpressionSyntax, StatementSyntax {
			return ex.pos()
		}
		token.Token {
			return ex.pos
		}
	}
}

pub struct EmptyExpr {
pub:
	kind SyntaxKind = .empty
	pos  util.Pos
}

pub fn (ee &EmptyExpr) child_nodes() []AstNode {
	return []AstNode{}
}

pub struct ComplationSyntax {
pub:
	kind        SyntaxKind = .comp_node
	eof_tok     token.Token
	pos         util.Pos
	stmt        StatementSyntax
	child_nodes []AstNode
}

pub fn new_comp_syntax(stmt StatementSyntax, eof_tok token.Token) ComplationSyntax {
	return ComplationSyntax{
		pos: stmt.pos()
		stmt: stmt
		eof_tok: eof_tok
		child_nodes: [AstNode(stmt)]
	}
}
pub fn (cn &ComplationSyntax) child_nodes() []AstNode {
	return cn.child_nodes
}
