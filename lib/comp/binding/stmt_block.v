module binding

import strings

pub struct BoundBlockStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .block_stmt
	child_nodes []BoundNode
	// child nodes
	stmts []BoundStmt
}

pub fn new_bound_block_stmt(stmts []BoundStmt) BoundBlockStmt {
	return BoundBlockStmt{
		stmts: stmts
		child_nodes: stmts.map(BoundNode(it))
	}
}

pub fn new_empty_block_stmt() BoundBlockStmt {
	return BoundBlockStmt{}
}

pub fn (ex BoundBlockStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundBlockStmt) str() string {
	mut b := strings.new_builder(0)
	b.writeln('{')
	for stmt in ex.stmts {
		b.writeln('\t$stmt')
	}
	b.writeln('}')
	return b.str()
}
