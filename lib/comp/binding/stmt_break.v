module binding

pub struct BoundBreakStmt {
pub:
	kind        BoundNodeKind = .break_stmt
	child_nodes []BoundNode
}

pub fn new_bound_break_stmt() BoundStmt {
	return BoundBreakStmt{}
}

pub fn (ex &BoundBreakStmt) node_str() string {
	return typeof(ex).name
}
