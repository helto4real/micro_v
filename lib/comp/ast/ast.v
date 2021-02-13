module ast
import token

// Sumtype expressions
pub type Expression = LiteralExpr | BinaryExpr | ParaExpr

// Nodes in syntax tree
pub type AstNode = Expression | token.Token
