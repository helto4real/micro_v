module binding

import lib.comp.symbols

pub struct BoundVarDeclStmt {
pub:
	kind        BoundNodeKind = .var_decl_stmt
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_mut      bool
	expr        BoundExpr
	var         symbols.VariableSymbol
}

pub fn new_var_decl_stmt(var symbols.VariableSymbol, expr BoundExpr, is_mut bool) BoundStmt {
	return BoundVarDeclStmt{
		var: var
		is_mut: is_mut
		typ: expr.typ
		expr: expr
		child_nodes: [BoundNode(expr)]
	}
}

pub fn (ex &BoundVarDeclStmt) node_str() string {
	return typeof(ex).name
}
