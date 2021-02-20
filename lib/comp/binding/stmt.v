module binding

pub struct BoundBlockStmt {
pub:
	kind  BoundNodeKind = .block_stmt
	bound_stmts []BoundStmt
} 

pub fn new_bound_block_stmt(bound_stmts []BoundStmt) BoundBlockStmt {
	return BoundBlockStmt {
		bound_stmts: bound_stmts
	}
}

pub struct BoundExprStmt {
pub:
	kind BoundNodeKind =.expr_stmt
	bound_expr BoundExpr
}

pub fn new_bound_expr_stmt(bound_expr BoundExpr) BoundExprStmt {
	return BoundExprStmt {
		bound_expr: bound_expr
	}
}