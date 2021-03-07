module binding

pub struct BoundContinueStmt {
pub:
	kind        BoundNodeKind = .cont_stmt
	child_nodes []BoundNode
}

pub fn new_bound_continue_stmt() BoundStmt {
	return BoundContinueStmt{}
}

pub fn (ex &BoundContinueStmt) node_str() string {
	return typeof(ex).name
}
