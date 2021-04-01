module binding

pub struct BoundIfStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .if_stmt
	child_nodes []BoundNode
	// child nodes
	cond_expr BoundExpr
	has_else  bool
	then_stmt BoundStmt
	else_stmt BoundStmt
}

fn new_if_stmt(cond_expr BoundExpr, then_stmt BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond_expr: cond_expr
		// typ: cond_expr.typ
		then_stmt: then_stmt
		child_nodes: [BoundNode(cond_expr), then_stmt]
	}
}

fn new_if_else_stmt(cond_expr BoundExpr, then_stmt BoundStmt, else_stmt BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond_expr: cond_expr
		then_stmt: then_stmt
		else_stmt: else_stmt
		has_else: true
		child_nodes: [BoundNode(cond_expr), then_stmt, else_stmt]
	}
}

pub fn (ex BoundIfStmt) node_str() string {
	return typeof(ex).name
}
