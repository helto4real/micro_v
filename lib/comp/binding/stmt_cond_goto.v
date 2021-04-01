module binding

pub struct BoundCondGotoStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .cond_goto_stmt
	child_nodes []BoundNode
	// child nodes
	cond_expr   BoundExpr
	true_label  string
	false_label string
}

pub fn new_bound_cond_goto_stmt(cond_expr BoundExpr, true_label string, false_label string) BoundStmt {
	return BoundCondGotoStmt{
		cond_expr: cond_expr
		true_label: true_label
		false_label: false_label
		child_nodes: [BoundNode(cond_expr)]
	}
}

pub fn (ex BoundCondGotoStmt) node_str() string {
	return typeof(ex).name
}
