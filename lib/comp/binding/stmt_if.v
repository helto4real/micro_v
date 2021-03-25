module binding

import lib.comp.symbols

pub struct BoundIfStmt {
pub:
	kind        BoundNodeKind = .if_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	cond_expr   BoundExpr
	has_else    bool
	block_stmt  BoundStmt
	else_clause BoundStmt
}

fn new_if_stmt(cond_expr BoundExpr, block_stmt BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond_expr: cond_expr
		typ: cond_expr.typ
		block_stmt: block_stmt
		child_nodes: [BoundNode(cond_expr), block_stmt]
	}
}

fn new_if_else_stmt(cond_expr BoundExpr, block_stmt BoundStmt, else_clause BoundStmt) BoundStmt {
	return BoundIfStmt{
		cond_expr: cond_expr
		typ: cond_expr.typ
		block_stmt: block_stmt
		else_clause: else_clause
		has_else: true
		child_nodes: [BoundNode(cond_expr), block_stmt, else_clause]
	}
}

pub fn (ex BoundIfStmt) node_str() string {
	return typeof(ex).name
}
