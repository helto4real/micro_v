module ast

import lib.comp.token
import lib.comp.util

// Sumtype expressions
pub type Expression = AssignExpr | BinaryExpr | EmptyExpr | LiteralExpr | NameExpr | ParaExpr |
	UnaryExpr | CompilationNode

pub fn (e &Expression) kind() SyntaxKind {
	match e {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, EmptyExpr, NameExpr, AssignExpr, CompilationNode {
			return e.kind
		}
	}
}

// Nodes in syntax tree
pub type AstNode = Expression | token.Token

pub fn (ex &Expression) children() []AstNode {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr, CompilationNode {
			return ex.child_nodes()
		}
	}
}

pub fn (ex &Expression) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr, CompilationNode {
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

pub fn (ee &EmptyExpr) child_nodes() []AstNode {
	return []AstNode{}
}


pub struct CompilationNode {
pub:
	kind SyntaxKind = .comp_node
	eof_tok token.Token
	pos  util.Pos
	expr Expression
	child_nodes []AstNode
}

pub fn new_comp_node(expr Expression, eof_tok token.Token) CompilationNode {
	return CompilationNode {
		pos: expr.pos()
		expr: expr
		eof_tok: eof_tok
		child_nodes: [AstNode(expr)]
	}
}
pub fn (cn &CompilationNode) child_nodes() []AstNode {
	return cn.child_nodes
}