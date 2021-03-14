module binding

import strings

pub struct BoundBlockStmt {
pub:
	kind        BoundNodeKind = .block_stmt
	child_nodes []BoundNode
	bound_stmts []BoundStmt
}

pub fn new_bound_block_stmt(bound_stmts []BoundStmt) BoundBlockStmt {
	return BoundBlockStmt{
		bound_stmts: bound_stmts
		child_nodes: bound_stmts.map(BoundNode(it))
	}
}

pub fn (ex BoundBlockStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundBlockStmt) str() string {
	mut b := strings.new_builder(0)
	b.writeln('{')
	for stmt in ex.bound_stmts {
		b.writeln('\t$stmt')
	}
	b.writeln('}')
	return b.str()
}
