module binding

import lib.comp.symbols

pub struct BoundVariableExpr {
pub:
	kind        BoundNodeKind = .variable_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	var         symbols.VariableSymbol
}

pub fn new_bound_variable_expr(var symbols.VariableSymbol) BoundExpr {
	return BoundVariableExpr{
		var: var
		typ: var.typ
	}
}

pub fn (ex BoundVariableExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundVariableExpr) str() string {
	return '$ex.var.name'
}
