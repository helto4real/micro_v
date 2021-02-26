module binding

pub struct BoundExprStmt {
pub:
	kind        BoundNodeKind = .expr_stmt
	child_nodes []BoundNode
	bound_expr  BoundExpr
}

pub fn new_bound_expr_stmt(bound_expr BoundExpr) BoundExprStmt {
	return BoundExprStmt{
		bound_expr: bound_expr
	}
}