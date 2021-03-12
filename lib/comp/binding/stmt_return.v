module binding

pub struct BoundReturnStmt {
pub:
	kind        BoundNodeKind = .return_stmt
	child_nodes []BoundNode
	has_expr    bool
	expr        BoundExpr
}

pub fn new_bound_return_with_expr_stmt(expr BoundExpr) BoundStmt {
	return BoundReturnStmt{
		expr: expr
		has_expr: true
	}
}

pub fn new_bound_return_stmt() BoundStmt {
	return BoundReturnStmt{
		has_expr: false
	}
}

pub fn (ex &BoundReturnStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex &BoundReturnStmt) str() string {
	if ex.has_expr {
		return 'return $ex.expr'
	} else {
		return 'return'
	}
}
