module binding

import lib.comp.symbols

pub struct BoundGotoStmt {
pub:
	kind        BoundNodeKind = .goto_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
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
