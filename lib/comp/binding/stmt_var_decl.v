module binding

import lib.comp.symbols

pub struct BoundVarDeclStmt {
pub:
	is_mut bool
	is_ref bool
	// general bound stmt
	kind        BoundNodeKind = .var_decl_stmt
	child_nodes []BoundNode
	// child nodes
	expr BoundExpr
	var  symbols.VariableSymbol
}

pub fn new_var_decl_stmt(var symbols.VariableSymbol, expr BoundExpr, is_mut bool) BoundStmt {
	return BoundVarDeclStmt{
		var: var
		is_mut: is_mut
		expr: expr
		child_nodes: [BoundNode(expr)]
	}
}

pub fn (ex BoundVarDeclStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundVarDeclStmt) str() string {
	return '$ex.var.name := $ex.expr'
}
