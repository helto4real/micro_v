module binding

import lib.comp.types

struct BoundAssignExpr {
pub:
	kind   BoundNodeKind = .assign_expr
	typ    types.Type
	is_mut bool
	expr   BoundExpr
	var    &VariableSymbol	
}

fn new_bound_assign_expr(var &VariableSymbol, is_mut bool, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		var: var
		is_mut: is_mut
		typ: expr.typ()
		expr: expr
	}
}
