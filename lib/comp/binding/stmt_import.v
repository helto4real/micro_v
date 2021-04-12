module binding

import lib.comp.token

pub struct BoundImportStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .import_stmt
	child_nodes []BoundNode
	// child nodes
	name        string
}

pub fn new_bound_import_stmt(tok_name token.Token) BoundStmt {
	return BoundImportStmt{
		name: tok_name.lit
	}
}

pub fn (ex BoundImportStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundImportStmt) str() string {
	return 'import $ex.name'
}
