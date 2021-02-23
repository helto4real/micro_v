module binding

import lib.comp.types

pub struct BoundForRangeStmt {
pub:
	kind BoundNodeKind = .for_range_stmt
	typ  types.Type

	ident &VariableSymbol
	range BoundExpr
	body  BoundStmt
}

fn new_for_range_stmt(ident &VariableSymbol, range BoundExpr, body BoundStmt) BoundStmt {
	return BoundForRangeStmt{
		ident: ident
		range: range
		body: body
	}
}

pub struct BoundForStmt {
pub:
	kind     BoundNodeKind = .for_stmt
	typ      types.Type
	has_cond bool

	cond BoundExpr
	body BoundStmt
}

fn new_for_stmt(cond BoundExpr, body BoundStmt, has_cond bool) BoundStmt {
	return BoundForStmt{
		cond: cond
		body: body
		has_cond: has_cond
	}
}
