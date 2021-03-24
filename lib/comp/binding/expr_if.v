module binding

import lib.comp.symbols

pub struct BoundIfExpr {
pub:
	kind        BoundNodeKind = .if_expr
	typ         symbols.BuiltInTypeSymbol
	child_nodes []BoundNode
	cond_expr   BoundExpr
	then_stmt   BoundStmt
	else_stmt   BoundStmt
}

pub fn new_if_else_expr(cond_expr BoundExpr, then_stmt BoundStmt, else_stmt BoundStmt) BoundExpr {
	// get last expression
	block := then_stmt as BoundBlockStmt
	last_expr := (block.child_nodes.last() as BoundStmt) as BoundExprStmt
	expr_typ := last_expr.bound_expr.typ
	return BoundIfExpr{
		child_nodes: [BoundNode(cond_expr), then_stmt, else_stmt]
		cond_expr: cond_expr
		typ: expr_typ
		then_stmt: then_stmt
		else_stmt: else_stmt
	}
}

pub fn (ex BoundIfExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex BoundIfExpr) str() string {
	return 'if $ex.cond_expr { $ex.then_stmt } else { $ex.else_stmt }'
}
