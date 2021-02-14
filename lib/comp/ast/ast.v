module ast
import token

// Sumtype expressions
pub type Expression = LiteralExpr | BinaryExpr | UnaryExpr | ParaExpr | EmptyExpr

pub fn (e Expression) kind() SyntaxKind {
	match e {
		LiteralExpr , BinaryExpr , UnaryExpr , ParaExpr , EmptyExpr {
			return e.kind
		}
	}
}
// Nodes in syntax tree
pub type AstNode = Expression | token.Token

pub struct EmptyExpr{
pub:
	kind SyntaxKind = .empty
}