module ast

import lib.comp.token
import lib.comp.util

// Sumtype expressions
pub type Expression = AssignExpr | BinaryExpr | EmptyExpr | LiteralExpr | NameExpr | ParaExpr |
	UnaryExpr

pub fn (e Expression) kind() SyntaxKind {
	match e {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, EmptyExpr, NameExpr, AssignExpr {
			return e.kind
		}
	}
}

// Nodes in syntax tree
pub type AstNode = Expression | token.Token

pub fn (ex &Expression) children() []AstNode {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr {
			return ex.child_nodes()
		}
	}
}

pub fn (ex &Expression) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr {
			return ex.pos
		}
	}
}

pub fn (ex &AstNode) pos() util.Pos {
	match ex {
		Expression {
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

pub fn (be &EmptyExpr) child_nodes() []AstNode {
	return []AstNode{}
}
