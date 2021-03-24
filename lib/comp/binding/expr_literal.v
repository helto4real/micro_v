module binding

import lib.comp.symbols

pub struct BoundLiteralExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.BuiltInTypeSymbol
	child_nodes []BoundNode
	const_val	symbols.ConstSymbol
}

pub fn new_bound_literal_expr(val symbols.LitVal) BoundExpr {
	return BoundLiteralExpr{
		typ: val.typ()
		kind: .literal_expr
		const_val: symbols.new_const_symbol(val)
	}
}

pub fn (ex BoundLiteralExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundLiteralExpr) str() string {
	return '$ex.const_val.val'
}
