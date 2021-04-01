module binding

pub struct BoundAssertStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .assert_stmt
	child_nodes []BoundNode
	// child nodes
	expr BoundExpr
}

pub fn new_bound_assert_stmt(expr BoundExpr) BoundStmt {
	return BoundAssertStmt{
		expr: expr
	}
}

pub fn (ex BoundAssertStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundAssertStmt) str() string {
	return 'assert $ex.expr.str()'
}
