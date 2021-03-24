module binding

import lib.comp.symbols

pub struct BoundRangeExpr {
pub:
	kind        BoundNodeKind = .range_expr
	typ         symbols.BuiltInTypeSymbol
	child_nodes []BoundNode
	from_exp    BoundExpr
	to_exp      BoundExpr
}

fn new_range_expr(from_exp BoundExpr, to_exp BoundExpr) BoundExpr {
	return BoundRangeExpr{
		child_nodes: [BoundNode(from_exp), to_exp]
		typ: from_exp.typ
		from_exp: from_exp
		to_exp: to_exp
	}
}

pub fn (ex BoundRangeExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundRangeExpr) str() string {
	return '${ex.from_exp}..$ex.to_exp'
}
