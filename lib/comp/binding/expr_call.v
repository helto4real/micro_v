module binding

import lib.comp.symbols

pub struct BoundCallExpr {
pub:
	kind        BoundNodeKind = .call_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	func        symbols.FunctionSymbol
	params      []BoundExpr
}

pub fn new_bound_call_expr(func symbols.FunctionSymbol, params []BoundExpr) BoundExpr {
	return BoundCallExpr{
		// child_nodes: [BoundNode(cond_expr), then_stmt, else_stmt]
		typ: func.typ
		func: func
		params: params
	}
}

pub fn (ex &BoundCallExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex &BoundCallExpr) str() string {
	// TODO: Gen parameters
	return 'fn ${ex.func.name}()'
}
