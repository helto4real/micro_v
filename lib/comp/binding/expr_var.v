module binding

import lib.comp.types

struct BoundVariableExpr {
pub:
	kind        BoundNodeKind = .variable_expr
	typ         types.Type
	child_nodes []BoundNode
	var         &VariableSymbol
}

fn new_bound_variable_expr(var &VariableSymbol) BoundExpr {
	return BoundVariableExpr{
		var: var
		typ: var.typ
	}
}

pub fn (ex &BoundVariableExpr) node_str() string {
	return typeof(ex).name
}
