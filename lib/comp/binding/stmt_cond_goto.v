module binding

import lib.comp.types

pub struct BoundCondGotoStmt {
pub:
	kind        BoundNodeKind = .for_range_stmt
	typ         types.Type
	child_nodes []BoundNode
	label		string
	cond	    BoundExpr
	jump_if_true bool
}

pub fn new_bound_cond_goto_stmt(label string, cond BoundExpr, jump_if_true bool) BoundStmt {
	return BoundCondGotoStmt{
		label: label
		cond: cond
		jump_if_true: jump_if_true
		child_nodes: [BoundNode(cond)]
	}
}

pub fn (ex &BoundCondGotoStmt) node_str() string {
	return typeof(ex).name
}