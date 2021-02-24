module binding

import lib.comp.types

pub struct BoundForRangeStmt {
pub:
	kind BoundNodeKind = .for_range_stmt
	typ  types.Type

	ident &VariableSymbol
	range_expr BoundExpr
	body_stmt  BoundStmt
}

fn new_for_range_stmt(ident &VariableSymbol, range_expr BoundExpr, body_stmt BoundStmt) BoundStmt {
	return BoundForRangeStmt{
		ident: ident
		range_expr: range_expr
		body_stmt: body_stmt
	}
}

pub struct BoundForStmt {
pub:
	kind     BoundNodeKind = .for_stmt
	typ      types.Type
	has_cond bool

	cond_expr BoundExpr
	body_stmt BoundStmt
}

fn new_for_stmt(cond_expr BoundExpr, body_stmt BoundStmt, has_cond bool) BoundStmt {
	return BoundForStmt{
		cond_expr: cond_expr
		body_stmt: body_stmt
		has_cond: has_cond
	}
}
