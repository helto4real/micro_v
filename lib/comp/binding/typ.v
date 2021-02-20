module binding

import lib.comp.types

type BoundExpr = BoundBinaryExpr | BoundLiteralExpr | BoundUnaryExpression | BoundVariableExpr | BoundAssignExpr

type BoundStmt = BoundBlockStmt | BoundExprStmt

type BoundNode = BoundExpr | BoundStmt

enum BoundNodeKind {
	// Expr
	unary_expr
	binary_expr
	literal_expr
	variable_expr
	assign_expr
	// Stmts
	block_stmt
	expr_stmt
}


pub fn (be BoundExpr) typ() types.Type {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr,
		BoundAssignExpr{
			return be.typ
		}
	}
}

pub fn (be BoundExpr) typ_str() string {
	match be {
		BoundLiteralExpr {
			return types.built_in_types[int(be.typ)]
		}
		BoundUnaryExpression, BoundBinaryExpr, BoundVariableExpr, BoundAssignExpr {
			return types.built_in_types[int(be.typ)]
		}
	}
}

pub fn (be BoundExpr) kind() BoundNodeKind {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr, BoundAssignExpr {
			return be.kind
		}
	}
}
