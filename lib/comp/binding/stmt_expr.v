module binding

pub struct BoundExprStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .expr_stmt
	child_nodes []BoundNode
	// child nodes
	expr BoundExpr
}

pub fn new_bound_expr_stmt(expr BoundExpr) BoundExprStmt {
	return BoundExprStmt{
		expr: expr
		child_nodes: [BoundNode(expr)]
	}
}

pub fn (ex BoundExprStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundExprStmt) str() string {
	return '$ex.expr'
}
