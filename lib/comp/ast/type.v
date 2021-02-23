module ast
import lib.comp.token
import lib.comp.util

// Sumtype statements
type Stmt = BlockStmt | ExprStmt | 
	VarDeclStmt | IfStmt | ForRangeStmt | ForStmt

// Sumtype expressions
pub type Expr = AssignExpr | BinaryExpr | CompExpr | LiteralExpr |
	NameExpr | ParaExpr | UnaryExpr | IfExpr | RangeExpr

// Nodes in syntax tree
pub type AstNode = Expr | Stmt | token.Token

pub fn (ex &AstNode) pos() util.Pos {
	match ex {
		Expr, Stmt {
			return ex.pos()
		}
		token.Token {
			return ex.pos
		}
	}
}

pub fn (e &Expr) kind() SyntaxKind {
	match e {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		CompExpr, IfExpr, RangeExpr
		{
			return e.kind
		}
	}
}

pub fn (ex &Expr) children() []AstNode {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		CompExpr, IfExpr, RangeExpr
		{
			return ex.child_nodes()
		}
	}
}

pub fn (ex &Expr) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		CompExpr, IfExpr, RangeExpr
		{
			return ex.pos
		}
	}
}

pub fn (ex &Stmt) children() []AstNode {
	match ex {
		BlockStmt, ExprStmt, VarDeclStmt, 
		IfStmt, ForRangeStmt, ForStmt {
			return ex.child_nodes()
		}
	}
}

pub fn (ex &Stmt) pos() util.Pos {
	match ex {
		BlockStmt, ExprStmt, VarDeclStmt, 
		IfStmt, ForRangeStmt, ForStmt {
			return ex.pos
		}
	}
}
