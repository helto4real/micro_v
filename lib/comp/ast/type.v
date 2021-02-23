module ast
import lib.comp.token
import lib.comp.util

// Sumtype statements
type StatementSyntax = BlockStatementSyntax | ExpressionStatementSyntax | 
	VarDeclStmtSyntax | IfStmtSyntax | ForRangeSyntax | ForSyntax

// Sumtype expressions
pub type ExpressionSyntax = AssignExpr | BinaryExpr | ComplationSyntax | LiteralExpr |
	NameExpr | ParaExpr | UnaryExpr | IfExprSyntax | RangeExprSyntax

// Nodes in syntax tree
pub type AstNode = ExpressionSyntax | StatementSyntax | token.Token

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

pub fn (e &ExpressionSyntax) kind() SyntaxKind {
	match e {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		ComplationSyntax, IfExprSyntax, RangeExprSyntax
		{
			return e.kind
		}
	}
}

pub fn (ex &ExpressionSyntax) children() []AstNode {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		ComplationSyntax, IfExprSyntax, RangeExprSyntax
		{
			return ex.child_nodes()
		}
	}
}

pub fn (ex &ExpressionSyntax) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, 
		ComplationSyntax, IfExprSyntax, RangeExprSyntax
		{
			return ex.pos
		}
	}
}

pub fn (ex &StatementSyntax) children() []AstNode {
	match ex {
		BlockStatementSyntax, ExpressionStatementSyntax, VarDeclStmtSyntax, 
		IfStmtSyntax, ForRangeSyntax, ForSyntax {
			return ex.child_nodes()
		}
	}
}

pub fn (ex &StatementSyntax) pos() util.Pos {
	match ex {
		BlockStatementSyntax, ExpressionStatementSyntax, VarDeclStmtSyntax, 
		IfStmtSyntax, ForRangeSyntax, ForSyntax {
			return ex.pos
		}
	}
}
