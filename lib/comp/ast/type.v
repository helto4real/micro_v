module ast

import lib.comp.token
import lib.comp.util

// Sumtype statements
pub type Stmt = BlockStmt | BreakStmt | ContinueStmt | ExprStmt | ForRangeStmt | ForStmt |
	IfStmt | ReturnStmt | VarDeclStmt

// Sumtype expressions
pub type Expr = AssignExpr | BinaryExpr | CallExpr | CompNode | IfExpr | LiteralExpr |
	NameExpr | ParaExpr | RangeExpr | UnaryExpr | EmptyExpr

// Nodes in syntax tree
pub type AstNode = Expr | MemberNode | ParamNode | Stmt | TypeNode | token.Token

// top level members like top level statements or function declarations
pub type MemberNode = FnDeclNode | GlobStmt

pub interface Node {
	child_nodes() []AstNode
	node_str() string
}

pub fn (ex &AstNode) pos() util.Pos {
	return ex.pos
}

pub fn (ex &AstNode) child_nodes() []AstNode {
	match ex {
		Expr { return ex.child_nodes }
		Stmt { return ex.child_nodes }
		token.Token { return []AstNode{} }
		TypeNode { return ex.child_nodes }
		ParamNode { return ex.child_nodes }
		MemberNode { return ex.child_nodes }
	}
}

pub fn (ex &AstNode) node_str() string {
	match ex {
		Expr { return ex.node_str() }
		Stmt { return ex.node_str() }
		token.Token { return ex.lit }
		TypeNode { return ex.node_str() }
		ParamNode { return ex.node_str() }
		MemberNode { return ex.node_str() }
	}
}

pub fn (e &Expr) kind() SyntaxKind {
	return e.kind
	// match e {
	// 	LiteralExpr { return e.kind }
	// 	BinaryExpr { return e.kind }
	// 	UnaryExpr { return e.kind }
	// 	ParaExpr { return e.kind }
	// 	NameExpr { return e.kind }
	// 	AssignExpr { return e.kind }
	// 	CompNode { return e.kind }
	// 	IfExpr { return e.kind }
	// 	RangeExpr { return e.kind }
	// 	CallExpr { return e.kind }
	// }
}

pub fn (ex &Expr) node_str() string {
	match ex {
		LiteralExpr { return ex.node_str() }
		BinaryExpr { return ex.node_str() }
		UnaryExpr { return ex.node_str() }
		ParaExpr { return ex.node_str() }
		NameExpr { return ex.node_str() }
		AssignExpr { return ex.node_str() }
		CompNode { return ex.node_str() }
		IfExpr { return ex.node_str() }
		RangeExpr { return ex.node_str() }
		CallExpr { return ex.node_str() }
		EmptyExpr { return ex.node_str() }
	}
}

pub fn (ex &Expr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex &Expr) pos() util.Pos {
	return ex.pos
}

pub fn (ex &Stmt) node_str() string {
	match ex {
		BlockStmt { return ex.node_str() }
		ExprStmt { return ex.node_str() }
		VarDeclStmt { return ex.node_str() }
		IfStmt { return ex.node_str() }
		ForRangeStmt { return ex.node_str() }
		ForStmt { return ex.node_str() }
		ContinueStmt { return ex.node_str() }
		BreakStmt { return ex.node_str() }
		ReturnStmt { return ex.node_str() }
	}
}

pub fn (ex &Stmt) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex &Stmt) pos() util.Pos {
	return ex.pos
}

pub fn (ex &MemberNode) node_str() string {
	match ex {
		GlobStmt { return ex.node_str() }
		FnDeclNode { return ex.node_str() }
	}
}

pub fn (ex &MemberNode) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex &MemberNode) pos() util.Pos {
	return ex.pos
}
