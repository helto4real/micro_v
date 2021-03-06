module binding

import lib.comp.symbols

pub struct BoundForRangeStmt {
pub:
	kind        BoundNodeKind = .for_range_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
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

pub fn (ex &BoundForRangeStmt) node_str() string {
	return typeof(ex).name
}
pub struct BoundForStmt {
pub:
	kind        BoundNodeKind = .for_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	has_cond    bool

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
pub fn (ex &BoundForStmt) node_str() string {
	return typeof(ex).name
}
