module binding

import lib.comp.token
import lib.comp.symbols

pub struct BoundAssignExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .assign_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	// child nodes
	var   symbols.VariableSymbol
	names []token.Token
	expr  BoundExpr
}

pub fn new_bound_assign_expr(var symbols.VariableSymbol, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		child_nodes: [BoundNode(expr)]
		var: var
		typ: expr.typ
		expr: expr
	}
}

pub fn new_bound_assign_with_names_expr(var symbols.VariableSymbol, names []token.Token, expr BoundExpr) BoundExpr {
	return BoundAssignExpr{
		child_nodes: [BoundNode(expr)]
		var: var
		names: names
		typ: expr.typ
		expr: expr
	}
}

pub fn (ex BoundAssignExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundAssignExpr) str() string {
	return '$ex.var.name = $ex.expr'
}

pub fn (ex BoundAssignExpr) to_ref_type() BoundAssignExpr {
	return BoundAssignExpr{
		...ex
		typ: ex.typ.to_ref_type()
	}
}
