module binding

pub type BoundExpr = BoundAssignExpr | BoundBinaryExpr | BoundCallExpr | BoundConvExpr |
	BoundEmptyExpr | BoundErrorExpr | BoundIfExpr | BoundLiteralExpr | BoundRangeExpr |
	BoundUnaryExpr | BoundVariableExpr

pub type BoundStmt = BoundBlockStmt | BoundBreakStmt | BoundCondGotoStmt | BoundContinueStmt |
	BoundExprStmt | BoundForRangeStmt | BoundForStmt | BoundGotoStmt | BoundIfStmt | BoundLabelStmt |
	BoundReturnStmt | BoundVarDeclStmt | BoundCommentStmt

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
	call_expr
	conv_expr
	error_expr
	// Stmts
	block_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	label_stmt
	break_stmt
	cont_stmt
	return_stmt
	for_range_stmt
	cond_goto_stmt
	goto_stmt
	comment_stmt
}

pub fn (bn &BoundNode) child_nodes() []BoundNode {
	return bn.child_nodes
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

pub fn (be BoundExpr) typ_str() string {
	return be.typ.name
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
		BoundErrorExpr { return be.node_str() }
		BoundCallExpr { return be.node_str() }
		BoundConvExpr { return be.node_str() }
		BoundEmptyExpr { return be.node_str() }
	}
}

pub fn (be BoundExpr) str() string {
	match be {
		BoundLiteralExpr { return be.str() }
		BoundUnaryExpr { return be.str() }
		BoundBinaryExpr { return be.str() }
		BoundVariableExpr { return be.str() }
		BoundAssignExpr { return be.str() }
		BoundIfExpr { return be.str() }
		BoundRangeExpr { return be.str() }
		BoundErrorExpr { return be.str() }
		BoundCallExpr { return be.str() }
		BoundConvExpr { return be.str() }
		BoundEmptyExpr { return be.str() }
	}
}

pub fn (be BoundExpr) kind() BoundNodeKind {
	return be.kind
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
		BoundBreakStmt { return bs.node_str() }
		BoundContinueStmt { return bs.node_str() }
		BoundReturnStmt { return bs.node_str() }
		BoundCommentStmt { return bs.node_str() }
	}
}
