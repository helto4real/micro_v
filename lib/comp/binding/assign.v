module binding

import lib.comp.types

struct BoundAssignExpr {
pub:
	kind   BoundNodeKind = .assign_expr
	typ    types.Type
	expr   BoundExpr
	var    &VariableSymbol	
}

fn new_bound_assign_expr(var &VariableSymbol, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		var: var
		typ: expr.typ()
		expr: expr
	}
}
