module binding

import lib.comp.types

type BoundExpr = BoundAssignExpr | BoundBinaryExpr | BoundIfExpr | BoundLiteralExpr |
	BoundRangeExpr | BoundUnaryExpression | BoundVariableExpr

type BoundStmt = BoundBlockStmt | BoundExprStmt | BoundForRangeStmt | BoundForStmt | BoundIfStmt |
	BoundVarDeclStmt

type BoundNode = BoundExpr | BoundStmt

enum BoundNodeKind {
	// Expr
	unary_expr
	binary_expr
	literal_expr
	variable_expr
	assign_expr
	if_expr
	range_expr
	// Stmts
	block_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	for_range_stmt
}

pub fn (be BoundExpr) typ() types.Type {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr, BoundAssignExpr,
		BoundIfExpr, BoundRangeExpr {
			return be.typ
		}
	}
}

pub fn (be BoundExpr) typ_str() string {
	match be {
		BoundLiteralExpr {
			return types.built_in_types[int(be.typ)]
		}
		BoundUnaryExpression, BoundBinaryExpr, BoundVariableExpr, BoundAssignExpr, BoundIfExpr,
		BoundRangeExpr {
			return types.built_in_types[int(be.typ)]
		}
	}
}

pub fn (be BoundExpr) kind() BoundNodeKind {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr, BoundAssignExpr,
		BoundIfExpr, BoundRangeExpr {
			return be.kind
		}
	}
}
