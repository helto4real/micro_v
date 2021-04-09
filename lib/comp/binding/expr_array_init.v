module binding

import lib.comp.symbols

pub struct BoundArrayInitExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .sruct_init_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	exprs []BoundExpr
}

pub fn new_bound_val_array_init_expr(typ symbols.TypeSymbol, exprs []BoundExpr) BoundExpr {
	return BoundArrayInitExpr{
		typ: typ
		exprs: exprs
	}
}

pub fn (ex BoundArrayInitExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundArrayInitExpr) str() string {
	return '[]$ex.typ.name'
}

pub fn (ex BoundArrayInitExpr) to_ref_type() BoundArrayInitExpr {
	return BoundArrayInitExpr{
		...ex
		typ: ex.typ.to_ref_type()
	}
}
