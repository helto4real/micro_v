module binding

import lib.comp.types

pub struct BoundIfExpr {
pub:
	kind      BoundNodeKind = .if_expr
	typ       types.Type
	cond_expr      BoundExpr
	then_stmt BoundStmt
	else_stmt BoundStmt
}

fn new_if_else_expr(cond_expr BoundExpr, then_stmt BoundStmt, else_stmt BoundStmt) BoundExpr {
	return BoundIfExpr{
		cond_expr: cond_expr
		typ: cond_expr.typ()
		then_stmt: then_stmt
		else_stmt: else_stmt
	}
}
