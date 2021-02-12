module ast
import token

// Sumtype expressions
pub type Expression = NumberExp | BinaryExpr | ParaExpr

pub type AstNode = Expression | token.Token
