module ast
import lib.comp.token

// Sumtype statements
type StatementSyntax = BlockStatementSyntax | ExpressionStatementSyntax | VarDeclStmtSyntax | IfStmtSyntax

// Sumtype expressions
pub type ExpressionSyntax = AssignExpr | BinaryExpr | ComplationSyntax | EmptyExpr | LiteralExpr |
	NameExpr | ParaExpr | UnaryExpr

// Nodes in syntax tree
pub type AstNode = ExpressionSyntax | StatementSyntax | ElseClauseSyntax | token.Token
