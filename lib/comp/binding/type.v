module binding

import lib.comp.symbols

pub type BoundExpr = BoundAssignExpr | BoundBinaryExpr | BoundIfExpr | BoundLiteralExpr |
	BoundRangeExpr | BoundUnaryExpr | BoundVariableExpr

pub type BoundStmt = BoundBlockStmt | BoundExprStmt | BoundForRangeStmt | BoundForStmt |
	BoundIfStmt | BoundVarDeclStmt | BoundGotoStmt | BoundLabelStmt | BoundCondGotoStmt

pub type BoundNode = BoundExpr | BoundStmt

pub enum BoundNodeKind {
	// Expr
	unary_expr
	binary_expr
	literal_expr
	variable_expr
	assign_expr
	if_expr
	range_expr
	// Stmts
	block_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	for_range_stmt
}

pub fn (bn &BoundNode) child_nodes() []BoundNode {
	match bn {
		BoundExpr { return bn.child_nodes() }
		BoundStmt { return bn.child_nodes() }
	}
}
pub fn (bn &BoundNode) node_str() string {
	match bn {
		BoundExpr {
			return bn.node_str()
		}
		BoundStmt {
			return bn.node_str()
		}
	}
}

pub fn (be BoundExpr) typ() symbols.TypeSymbol {
	match be {
		BoundLiteralExpr { return be.typ }
		BoundUnaryExpr { return be.typ }
		BoundBinaryExpr { return be.typ }
		BoundVariableExpr { return be.typ }
		BoundAssignExpr { return be.typ }
		BoundIfExpr { return be.typ }
		BoundRangeExpr { return be.typ }
	}
}

pub fn (be BoundExpr) typ_str() string {
	match be {
		BoundLiteralExpr { return be.typ.name }
		BoundUnaryExpr { return be.typ.name }
		BoundBinaryExpr { return be.typ.name }
		BoundVariableExpr { return be.typ.name }
		BoundAssignExpr { return be.typ.name }
		BoundIfExpr { return be.typ.name }
		BoundRangeExpr { return be.typ.name }
	}
}
pub fn (be BoundExpr) node_str() string {
	match be {
		BoundLiteralExpr { return be.node_str() }
		BoundUnaryExpr { return be.node_str() }
		BoundBinaryExpr { return be.node_str() }
		BoundVariableExpr { return be.node_str() }
		BoundAssignExpr { return be.node_str() }
		BoundIfExpr { return be.node_str() }
		BoundRangeExpr { return be.node_str() }
	}
}

pub fn (be BoundExpr) kind() BoundNodeKind {
	match be {
		BoundUnaryExpr { return be.kind }
		BoundBinaryExpr { return be.kind }
		BoundLiteralExpr { return be.kind }
		BoundVariableExpr { return be.kind }
		BoundAssignExpr { return be.kind }
		BoundIfExpr { return be.kind }
		BoundRangeExpr { return be.kind }
	}
}

pub fn (be BoundExpr) child_nodes() []BoundNode {
	match be {
		BoundUnaryExpr { return be.child_nodes }
		BoundBinaryExpr { return be.child_nodes }
		BoundLiteralExpr { return be.child_nodes }
		BoundVariableExpr { return be.child_nodes }
		BoundAssignExpr { return be.child_nodes }
		BoundIfExpr { return be.child_nodes }
		BoundRangeExpr { return be.child_nodes }
	}
}

pub fn (bs BoundStmt) child_nodes() []BoundNode {
	match bs {
		BoundBlockStmt { return bs.child_nodes }
		BoundExprStmt { return bs.child_nodes }
		BoundForRangeStmt { return bs.child_nodes }
		BoundForStmt { return bs.child_nodes }
		BoundIfStmt { return bs.child_nodes }
		BoundVarDeclStmt { return bs.child_nodes }
		BoundGotoStmt { return bs.child_nodes }
		BoundCondGotoStmt { return bs.child_nodes }
		BoundLabelStmt { return bs.child_nodes }
	}
}
pub fn (bs BoundStmt) node_str() string {
	match bs {
		BoundBlockStmt { return bs.node_str() }
		BoundExprStmt { return bs.node_str() }
		BoundForRangeStmt { return bs.node_str() }
		BoundForStmt { return bs.node_str() }
		BoundIfStmt { return bs.node_str() }
		BoundVarDeclStmt { return bs.node_str() }
		BoundGotoStmt { return bs.node_str() }
		BoundCondGotoStmt { return bs.node_str() }
		BoundLabelStmt { return bs.node_str() }
	}
}
