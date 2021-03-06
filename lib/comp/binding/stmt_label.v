module binding

import lib.comp.symbols

pub struct BoundLabelStmt {
pub:
	kind        BoundNodeKind = .label_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	name        string
}

pub fn new_bound_label_stmt(name string) BoundStmt {
	return BoundLabelStmt{
		name: name
	}
}

pub fn (ex &BoundLabelStmt) node_str() string {
	return typeof(ex).name
}
