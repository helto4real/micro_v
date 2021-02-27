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
		child_nodes: [BoundNode(bound_expr)]
	}
}

pub fn (ex &BoundExprStmt) node_str() string {
	return typeof(ex).name
}