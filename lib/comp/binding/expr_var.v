module binding

import lib.comp.symbols
import lib.comp.token

pub struct BoundVariableExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .variable_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	names  []token.Token
	var    symbols.VariableSymbol
}

pub fn new_bound_variable_expr(var symbols.VariableSymbol, typ symbols.TypeSymbol) BoundExpr {
	return BoundVariableExpr{
		var: var
		typ: typ
	}
}

pub fn new_bound_variable_with_names_expr(var symbols.VariableSymbol, names []token.Token, typ symbols.TypeSymbol) BoundExpr {
	return BoundVariableExpr{
		var: var
		names: names
		typ: typ
	}
}

pub fn (ex BoundVariableExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundVariableExpr) str() string {
	return '$ex.var.name'
}

pub fn (ex BoundVariableExpr) to_ref_type() BoundVariableExpr {
	return BoundVariableExpr{
		...ex
		typ: ex.typ.to_ref_type()
	}
}
