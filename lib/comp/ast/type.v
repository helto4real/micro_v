module ast

import lib.comp.token
import lib.comp.util.source

// Sumtype statements
pub type Stmt = AssertStmt | BlockStmt | BreakStmt | CommentStmt | ContinueStmt | ExprStmt |
	ForRangeStmt | ForStmt | IfStmt | ModuleStmt | ReturnStmt | VarDeclStmt

// Sumtype expressions
pub type Expr = AssignExpr | BinaryExpr | CallExpr | CompNode | IfExpr | LiteralExpr |
	NameExpr | NoneExpr | ParaExpr | RangeExpr | StructInitExpr | UnaryExpr | ArrayInitExpr

// Nodes in syntax tree
pub type AstNode = EmptyNode | Expr | MemberNode | ParamNode | Stmt | StructInitMemberNode |
	StructMemberNode | TypeNode | token.Token

// top level members like top level statements or function declarations
pub type MemberNode = FnDeclNode | GlobStmt | StructDeclNode

pub interface Node {
	child_nodes() []AstNode
	node_str() string
}

pub fn (ex &AstNode) child_nodes() []AstNode {
	match ex {
		Expr { return ex.child_nodes }
		Stmt { return ex.child_nodes }
		token.Token { return []AstNode{} }
		TypeNode { return ex.child_nodes }
		StructMemberNode { return ex.child_nodes }
		StructInitMemberNode { return ex.child_nodes }
		ParamNode { return ex.child_nodes }
		MemberNode { return ex.child_nodes }
		EmptyNode { return ex.child_nodes }
	}
}

pub fn (ex AstNode) text_location() source.TextLocation {
	match ex {
		Expr { return ex.text_location() }
		Stmt { return ex.text_location() }
		token.Token { return ex.text_location() }
		TypeNode { return ex.text_location() }
		StructMemberNode { return ex.text_location() }
		StructInitMemberNode { return ex.text_location() }
		ParamNode { return ex.text_location() }
		MemberNode { return ex.text_location() }
		EmptyNode { return ex.text_location() }
	}
}

pub fn (ex AstNode) node_str() string {
	match ex {
		Expr { return ex.node_str() }
		Stmt { return ex.node_str() }
		token.Token { return ex.lit }
		TypeNode { return ex.node_str() }
		StructMemberNode { return ex.node_str() }
		StructInitMemberNode { return ex.node_str() }
		ParamNode { return ex.node_str() }
		MemberNode { return ex.node_str() }
		EmptyNode { return ex.node_str() }
	}
}

pub fn (ex AstNode) str() string {
	match ex {
		Expr { return ex.str() }
		Stmt { return ex.str() }
		token.Token { return ex.lit }
		TypeNode { return ex.str() }
		StructMemberNode { return ex.str() }
		StructInitMemberNode { return ex.str() }
		ParamNode { return ex.str() }
		MemberNode { return ex.str() }
		EmptyNode { return ex.str() }
	}
}

pub fn (e &Expr) kind() SyntaxKind {
	return e.kind
}

pub fn (ex Expr) text_location() source.TextLocation {
	match ex {
		LiteralExpr { return ex.text_location() }
		BinaryExpr { return ex.text_location() }
		UnaryExpr { return ex.text_location() }
		ParaExpr { return ex.text_location() }
		NameExpr { return ex.text_location() }
		AssignExpr { return ex.text_location() }
		CompNode { return ex.text_location() }
		IfExpr { return ex.text_location() }
		RangeExpr { return ex.text_location() }
		CallExpr { return ex.text_location() }
		NoneExpr { return ex.text_location() }
		StructInitExpr { return ex.text_location() }
		ArrayInitExpr { return ex.text_location() }
	}
}

pub fn (ex Expr) node_str() string {
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
		NoneExpr { return ex.node_str() }
		StructInitExpr { return ex.node_str() }
		ArrayInitExpr { return ex.node_str() }
	}
}

pub fn (ex Expr) str() string {
	match ex {
		LiteralExpr { return ex.str() }
		BinaryExpr { return ex.str() }
		UnaryExpr { return ex.str() }
		ParaExpr { return ex.str() }
		NameExpr { return ex.str() }
		AssignExpr { return ex.str() }
		CompNode { return ex.str() }
		IfExpr { return ex.str() }
		RangeExpr { return ex.str() }
		CallExpr { return ex.str() }
		NoneExpr { return ex.str() }
		StructInitExpr { return ex.str() }
		ArrayInitExpr { return ex.str() }
	}
}

pub fn (ex &Expr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex Stmt) text_location() source.TextLocation {
	match ex {
		BlockStmt { return ex.text_location() }
		ExprStmt { return ex.text_location() }
		VarDeclStmt { return ex.text_location() }
		IfStmt { return ex.text_location() }
		ForRangeStmt { return ex.text_location() }
		ForStmt { return ex.text_location() }
		ContinueStmt { return ex.text_location() }
		BreakStmt { return ex.text_location() }
		ReturnStmt { return ex.text_location() }
		CommentStmt { return ex.text_location() }
		ModuleStmt { return ex.text_location() }
		AssertStmt { return ex.text_location() }
	}
}

pub fn (ex Stmt) node_str() string {
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
		CommentStmt { return ex.node_str() }
		ModuleStmt { return ex.node_str() }
		AssertStmt { return ex.node_str() }
	}
}

pub fn (ex Stmt) str() string {
	match ex {
		BlockStmt { return ex.str() }
		ExprStmt { return ex.str() }
		VarDeclStmt { return ex.str() }
		IfStmt { return ex.str() }
		ForRangeStmt { return ex.str() }
		ForStmt { return ex.str() }
		ContinueStmt { return ex.str() }
		BreakStmt { return ex.str() }
		ReturnStmt { return ex.str() }
		CommentStmt { return ex.str() }
		ModuleStmt { return ex.str() }
		AssertStmt { return ex.str() }
	}
}

pub fn (ex &Stmt) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex MemberNode) node_str() string {
	match ex {
		GlobStmt { return ex.node_str() }
		FnDeclNode { return ex.node_str() }
		StructDeclNode { return ex.node_str() }
	}
}

pub fn (ex MemberNode) text_location() source.TextLocation {
	match ex {
		GlobStmt { return ex.text_location() }
		FnDeclNode { return ex.text_location() }
		StructDeclNode { return ex.text_location() }
	}
}

pub fn (ex &MemberNode) child_nodes() []AstNode {
	return ex.child_nodes
}
