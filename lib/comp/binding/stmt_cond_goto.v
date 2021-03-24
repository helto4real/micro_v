module binding

import lib.comp.symbols

pub struct BoundCondGotoStmt {
pub:
	kind         BoundNodeKind = .cond_goto_stmt
	typ          symbols.BuiltInTypeSymbol
	child_nodes  []BoundNode
	cond         BoundExpr
	true_label        string
	false_label        string
}

pub fn new_bound_cond_goto_stmt(cond BoundExpr, true_label string, false_label string) BoundStmt {
	return BoundCondGotoStmt{
		cond: cond
		true_label: true_label
		false_label: false_label
		child_nodes: [BoundNode(cond)]
	}
}

pub fn (ex BoundCondGotoStmt) node_str() string {
	return typeof(ex).name
}
