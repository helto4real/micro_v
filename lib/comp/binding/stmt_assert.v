module binding

pub struct BoundAssertStmt {
pub:
	kind        BoundNodeKind = .assert_stmt
	child_nodes []BoundNode
	bound_expr        BoundExpr
}

pub fn new_bound_assert_stmt(bound_expr BoundExpr) BoundStmt {
	return BoundAssertStmt{
		bound_expr: bound_expr
	}
}

pub fn (ex BoundAssertStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundAssertStmt) str() string {
	return 'assert ${ex.bound_expr.str()}'
}
