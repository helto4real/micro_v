module binding

import lib.comp.token

pub struct BoundModuleStmt {
pub:
	kind        BoundNodeKind = .module_stmt
	child_nodes []BoundNode
	name        string
}

pub fn new_bound_module_stmt(tok_name token.Token) BoundStmt {
	return BoundModuleStmt{
		name: tok_name.lit
	}
}

pub fn (ex BoundModuleStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundModuleStmt) str() string {
	return 'module $ex.name'
}
