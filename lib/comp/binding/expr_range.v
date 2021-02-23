module binding

import lib.comp.types

pub struct BoundRangeExpr {
pub:
	kind      BoundNodeKind = .range_expr
	typ       types.Type
	from_exp  BoundExpr
	to_exp    BoundExpr
}

fn new_range_expr(from_exp BoundExpr, to_exp BoundExpr) BoundExpr {
	return BoundRangeExpr{
		typ: from_exp.typ()
		from_exp: from_exp
		to_exp: to_exp
	}
}