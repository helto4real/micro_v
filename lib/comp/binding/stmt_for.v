module binding

import lib.comp.symbols

pub struct BoundForRangeStmt {
pub:
	// general bound stmt
	kind        BoundNodeKind = .for_range_stmt
	child_nodes []BoundNode
	// child nodes
	ident       symbols.VariableSymbol
	range_expr  BoundExpr
	body_stmt   BoundStmt
}

fn new_for_range_stmt(ident symbols.VariableSymbol, range_expr BoundExpr, body_stmt BoundStmt) BoundStmt {
	return BoundForRangeStmt{
		ident: ident
		range_expr: range_expr
		body_stmt: body_stmt
		child_nodes: [BoundNode(range_expr), body_stmt]
	}
}

pub fn (ex BoundForRangeStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundForRangeStmt) str() string {
	return 'for $ex.ident.name in $ex.range_expr $ex.body_stmt'
}

pub struct BoundForStmt {
pub:
	has_cond    bool
	// general bound stmt
	kind        BoundNodeKind = .for_stmt
	child_nodes []BoundNode
	// child nodes
	cond_expr BoundExpr
	body_stmt BoundStmt
}

pub fn new_for_stmt(cond_expr BoundExpr, body_stmt BoundStmt, has_cond bool) BoundStmt {
	return BoundForStmt{
		cond_expr: cond_expr
		body_stmt: body_stmt
		has_cond: has_cond
		child_nodes: [BoundNode(cond_expr), body_stmt]
	}
}

pub fn (ex BoundForStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundForStmt) str() string {
	if ex.has_cond {
		return 'for $ex.cond_expr $ex.body_stmt'
	} else {
		return 'for $ex.body_stmt'
	}
}
