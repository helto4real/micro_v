module binding

import lib.comp.symbols

pub struct BoundCallExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .call_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
	// child nodes
	func   symbols.FunctionSymbol
	params []BoundExpr
}

pub fn new_bound_call_expr(func symbols.FunctionSymbol, params []BoundExpr) BoundExpr {
	return BoundCallExpr{
		typ: func.typ
		func: func
		params: params
	}
}

pub fn (ex BoundCallExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundCallExpr) str() string {
	// TODO: Gen parameters
	return 'fn ${ex.func.name}()'
}

pub fn (ex BoundCallExpr) to_ref_type() BoundCallExpr {
	return BoundCallExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}
