module ast
import token

// Sumtype expressions
pub type Expression = LiteralExpr | BinaryExpr | UnaryExpr | ParaExpr | EmptyExpr

// Nodes in syntax tree
pub type AstNode = Expression | token.Token

pub struct EmptyExpr{

}