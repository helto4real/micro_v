module ast

import lib.comp.token
import lib.comp.util

// Sumtype statements
pub type Stmt = BlockStmt | BreakStmt | ContinueStmt | ExprStmt | ForRangeStmt | ForStmt |
	IfStmt | VarDeclStmt

// Sumtype expressions
pub type Expr = AssignExpr | BinaryExpr | CallExpr | CompNode | IfExpr | LiteralExpr |
	NameExpr | ParaExpr | RangeExpr | UnaryExpr

// Nodes in syntax tree
pub type AstNode = Expr | MemberNode | ParamNode | Stmt | TypeNode | token.Token

// top level members like top level statements or function declarations
pub type MemberNode = FnDeclNode | GlobStmt

pub interface Node {
	child_nodes() []AstNode
	node_str() string
}

pub fn (ex &AstNode) pos() util.Pos {
	match ex {
		Stmt { return ex.pos() }
		Expr { return ex.pos() }
		token.Token { return ex.pos }
		TypeNode { return ex.pos }
		ParamNode { return ex.pos }
		MemberNode { return ex.pos() }
	}
}

pub fn (ex &AstNode) child_nodes() []AstNode {
	match ex {
		Expr { return ex.child_nodes() }
		Stmt { return ex.child_nodes() }
		token.Token { return []AstNode{} }
		TypeNode { return ex.child_nodes() }
		ParamNode { return ex.child_nodes() }
		MemberNode { return ex.child_nodes() }
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
	match e {
		LiteralExpr { return e.kind }
		BinaryExpr { return e.kind }
		UnaryExpr { return e.kind }
		ParaExpr { return e.kind }
		NameExpr { return e.kind }
		AssignExpr { return e.kind }
		CompNode { return e.kind }
		IfExpr { return e.kind }
		RangeExpr { return e.kind }
		CallExpr { return e.kind }
	}
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
	}
}

pub fn (ex &Expr) child_nodes() []AstNode {
	match ex {
		LiteralExpr { return ex.child_nodes }
		BinaryExpr { return ex.child_nodes }
		UnaryExpr { return ex.child_nodes }
		ParaExpr { return ex.child_nodes }
		NameExpr { return ex.child_nodes }
		AssignExpr { return ex.child_nodes }
		CompNode { return ex.child_nodes }
		IfExpr { return ex.child_nodes }
		RangeExpr { return ex.child_nodes }
		CallExpr { return ex.child_nodes }
	}
}

pub fn (ex &Expr) pos() util.Pos {
	match ex {
		LiteralExpr { return ex.pos }
		BinaryExpr { return ex.pos }
		UnaryExpr { return ex.pos }
		ParaExpr { return ex.pos }
		NameExpr { return ex.pos }
		AssignExpr { return ex.pos }
		CompNode { return ex.pos }
		IfExpr { return ex.pos }
		RangeExpr { return ex.pos }
		CallExpr { return ex.pos }
	}
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
	}
}

pub fn (ex &Stmt) child_nodes() []AstNode {
	match ex {
		BlockStmt { return ex.child_nodes() }
		ExprStmt { return ex.child_nodes() }
		VarDeclStmt { return ex.child_nodes() }
		IfStmt { return ex.child_nodes() }
		ForRangeStmt { return ex.child_nodes() }
		ForStmt { return ex.child_nodes() }
		ContinueStmt { return ex.child_nodes() }
		BreakStmt { return ex.child_nodes() }
	}
}

pub fn (ex &Stmt) pos() util.Pos {
	match ex {
		BlockStmt { return ex.pos }
		ExprStmt { return ex.pos }
		VarDeclStmt { return ex.pos }
		IfStmt { return ex.pos }
		ForRangeStmt { return ex.pos }
		ForStmt { return ex.pos }
		ContinueStmt { return ex.pos }
		BreakStmt { return ex.pos }
	}
}

pub fn (ex &MemberNode) node_str() string {
	match ex {
		GlobStmt { return ex.node_str() }
		FnDeclNode { return ex.node_str() }
	}
}

pub fn (ex &MemberNode) child_nodes() []AstNode {
	match ex {
		GlobStmt { return ex.child_nodes() }
		FnDeclNode { return ex.child_nodes() }
	}
}

pub fn (ex &MemberNode) pos() util.Pos {
	match ex {
		GlobStmt { return ex.pos }
		FnDeclNode { return ex.pos }
	}
}
