module binding

pub struct BoundGotoStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .goto_stmt
	child_nodes []BoundNode
	// child nodes
	label       string
}

pub fn new_bound_goto_stmt(label string) BoundStmt {
	return BoundGotoStmt{
		label: label
	}
}

pub fn (ex BoundGotoStmt) node_str() string {
	return typeof(ex).name
}
