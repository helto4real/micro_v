module binding

import lib.comp.types

pub struct BoundVarDeclStmt {
pub:
	kind        BoundNodeKind = .var_decl_stmt
	typ         types.Type
	child_nodes []BoundNode
	is_mut      bool
	expr        BoundExpr
	var         &VariableSymbol
}

fn new_var_decl_stmt(var &VariableSymbol, expr BoundExpr, is_mut bool) BoundStmt {
	return BoundVarDeclStmt{
		var: var
		is_mut: is_mut
		typ: expr.typ()
		expr: expr
	}
}

pub fn (ex &BoundVarDeclStmt) node_str() string {
	return typeof(ex).name
}
