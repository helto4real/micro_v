module binding

import lib.comp.types

pub struct BoundBlockStmt {
pub:
	kind        BoundNodeKind = .block_stmt
	child_nodes []BoundNode
	bound_stmts []BoundStmt
}

pub fn new_bound_block_stmt(bound_stmts []BoundStmt) BoundBlockStmt {
	return BoundBlockStmt{
		bound_stmts: bound_stmts
		child_nodes: bound_stmts.map(BoundNode(it))
	}
}

pub fn (ex &BoundBlockStmt) node_str() string {
	return typeof(ex).name
}

pub struct BoundExprStmt {
pub:
	kind        BoundNodeKind = .expr_stmt
	child_nodes []BoundNode
	bound_expr  BoundExpr
}

pub fn new_bound_expr_stmt(bound_expr BoundExpr) BoundExprStmt {
	return BoundExprStmt{
		bound_expr: bound_expr
	}
}

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
