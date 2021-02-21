module ast

// Sumtype statements
type StatementSyntax = BlockStatementSyntax | ExpressionStatementSyntax | VarDeclStmtSyntax

// Sumtype expressions
pub type ExpressionSyntax = AssignExpr | BinaryExpr | ComplationSyntax | EmptyExpr | LiteralExpr |
	NameExpr | ParaExpr | UnaryExpr
