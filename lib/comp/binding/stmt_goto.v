module binding

import lib.comp.types

pub struct BoundGotoStmt {
pub:
	kind        BoundNodeKind = .for_range_stmt
	typ         types.Type
	child_nodes []BoundNode
	label		string
}

pub fn new_bound_goto_stmt(label string) BoundStmt {
	return BoundGotoStmt{
		label: label
	}
}

pub fn (ex &BoundGotoStmt) node_str() string {
	return typeof(ex).name
}