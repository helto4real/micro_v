module binding

import lib.comp.types

pub struct BoundIfStmt {
pub:
	kind        BoundNodeKind = .if_stmt
	typ         types.Type
	cond        BoundExpr
	has_else    bool
	block_stmt  BoundStmt
	else_clause BoundStmt
}

fn new_if_stmt(cond BoundExpr, block_stmt BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond: cond
		typ: cond.typ()
		block_stmt: block_stmt
	}
}
fn new_if_else_stmt(cond BoundExpr, block_stmt BoundStmt, else_clause BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond: cond
		typ: cond.typ()
		block_stmt: block_stmt
		else_clause: else_clause
		has_else: true
	}
}
