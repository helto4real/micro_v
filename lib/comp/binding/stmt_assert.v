module binding

import lib.comp.util.source

pub struct BoundAssertStmt {
pub:
	location source.TextLocation
	// general bound stmt
	kind        BoundNodeKind = .assert_stmt
	child_nodes []BoundNode
	// child nodes
	expr BoundExpr
	code string
}

pub fn new_bound_assert_stmt(location source.TextLocation, expr BoundExpr, code string) BoundStmt {
	return BoundAssertStmt{
		location: location
		expr: expr
		code: code
	}
}

pub fn (ex BoundAssertStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundAssertStmt) str() string {
	return 'assert $ex.expr.str()'
}
