module binding

import lib.comp.symbols

pub struct BoundCondGotoStmt {
pub:
	kind         BoundNodeKind = .cond_goto_stmt
	typ          symbols.TypeSymbol
	child_nodes  []BoundNode
	label        string
	cond         BoundExpr
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
