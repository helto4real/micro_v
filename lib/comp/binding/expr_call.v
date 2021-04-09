module binding

import lib.comp.symbols

pub struct BoundCallExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .call_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_c_call   bool
	// child nodes
	func     symbols.FunctionSymbol
	receiver symbols.LocalVariableSymbol

	params []BoundExpr
}

pub fn new_bound_call_expr(func symbols.FunctionSymbol, receiver symbols.LocalVariableSymbol, params []BoundExpr, is_c_call bool) BoundExpr {
	return BoundCallExpr{
		typ: func.typ
		is_c_call: is_c_call
		func: func
		receiver: receiver
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
		typ: ex.typ.to_ref_type()
	}
}
