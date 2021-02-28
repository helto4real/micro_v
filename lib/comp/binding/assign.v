module binding

import lib.comp.types
import lib.comp.symbols

pub struct BoundAssignExpr {
pub:
	kind        BoundNodeKind = .assign_expr
	typ         types.Type
	child_nodes []BoundNode
	expr        BoundExpr
	var         &symbols.VariableSymbol
}

pub fn new_bound_assign_expr(var &symbols.VariableSymbol, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		child_nodes: [BoundNode(expr)]
		var: var
		typ: expr.typ()
		expr: expr
	}
}

pub fn (ex &BoundAssignExpr) node_str() string {
	return typeof(ex).name
}
