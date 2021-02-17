module ast
import token

// Sumtype expressions
pub type Expression = LiteralExpr | BinaryExpr | UnaryExpr | ParaExpr | NameExpr | EmptyExpr | AssignExpr

pub fn (e Expression) kind() SyntaxKind {
	match e {
		LiteralExpr , BinaryExpr , UnaryExpr , ParaExpr , EmptyExpr, NameExpr,
		AssignExpr {
			return e.kind
		}
	}
}

// Nodes in syntax tree
pub type AstNode = Expression | token.Token

pub fn (ex &Expression) children() []AstNode {
	match ex {
		LiteralExpr {
			// lit_expr := unsafe { &LiteralExpr(ex) }
			return ex.child_nodes()
		} 
		BinaryExpr, UnaryExpr, ParaExpr, NameExpr, EmptyExpr, AssignExpr {
			return  ex.child_nodes()
		}
	}
}

pub struct EmptyExpr{
pub:
	kind SyntaxKind = .empty
}

pub fn (be &EmptyExpr) child_nodes() []AstNode {
	return  []AstNode{}
}