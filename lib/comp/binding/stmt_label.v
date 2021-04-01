module binding

pub struct BoundLabelStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .label_stmt
	child_nodes []BoundNode
	// child nodes
	name string
}

pub fn new_bound_label_stmt(name string) BoundStmt {
	return BoundLabelStmt{
		name: name
	}
}

pub fn (ex BoundLabelStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundLabelStmt) str() string {
	return '$ex.name:'
}
