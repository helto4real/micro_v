module binding

import lib.comp.symbols

pub struct BoundLiteralExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .literal_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	const_val symbols.ConstSymbol
}

pub fn new_bound_literal_expr(val symbols.LitVal) BoundExpr {
	return BoundLiteralExpr{
		typ: val.typ()
		const_val: symbols.new_const_symbol(val)
	}
}

pub fn (ex BoundLiteralExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundLiteralExpr) str() string {
	return '$ex.const_val.val'
}

pub fn (ex BoundLiteralExpr) to_ref_type() BoundLiteralExpr {
	return BoundLiteralExpr{
		...ex
		typ: ex.typ.to_ref_type()
	}
}
