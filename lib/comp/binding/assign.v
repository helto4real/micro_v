module binding

import lib.comp.types

struct BoundAssignExpr {
pub:
	kind   BoundNodeKind = .assign_expr
	typ    types.Type
	is_mut bool
	name   string
	expr   BoundExpr
}

fn new_bound_assign_expr(name string, is_mut bool, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		name: name
		is_mut: is_mut
		typ: expr.typ()
		expr: expr
	}
}
