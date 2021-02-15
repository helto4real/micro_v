module binding

import lib.comp.types


struct BoundAssignExpr {
pub:
	kind BoundNodeKind = .assign_expr
	typ  types.Type
	name string
	expr  BoundExpr
}

fn new_bound_assign_expr(name string, expr BoundExpr) BoundExpr {
	return BoundAssignExpr {
		name: name
		typ: expr.typ()
		expr: expr
	}
}

