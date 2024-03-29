module binding

pub type BoundExpr = BoundArrayInitExpr | BoundAssignExpr | BoundBinaryExpr | BoundCallExpr |
	BoundConvExpr | BoundErrorExpr | BoundIfExpr | BoundIndexExpr | BoundLiteralExpr |
	BoundNoneExpr | BoundRangeExpr | BoundStructInitExpr | BoundUnaryExpr | BoundVariableExpr |
	NoneExpr

pub type BoundStmt = BoundAssertStmt | BoundBlockStmt | BoundBreakStmt | BoundCommentStmt |
	BoundCondGotoStmt | BoundContinueStmt | BoundExprStmt | BoundForRangeStmt | BoundForStmt |
	BoundGotoStmt | BoundIfStmt | BoundLabelStmt | BoundModuleStmt | BoundReturnStmt |
	BoundVarDeclStmt | BoundImportStmt

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
	sruct_init_expr
	index_expr
	none_expr
	// Stmts
	block_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	label_stmt
	break_stmt
	continue_stmt
	return_stmt
	for_range_stmt
	cond_goto_stmt
	goto_stmt
	comment_stmt
	module_stmt
	import_stmt
	assert_stmt
}

pub fn (bn &BoundNode) child_nodes() []BoundNode {
	return bn.child_nodes
}

pub fn (bn BoundNode) node_str() string {
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
		BoundIndexExpr { return be.node_str() }
		BoundErrorExpr { return be.node_str() }
		BoundCallExpr { return be.node_str() }
		BoundConvExpr { return be.node_str() }
		BoundNoneExpr { return be.node_str() }
		BoundArrayInitExpr { return be.node_str() }
		BoundStructInitExpr { return be.node_str() }
		NoneExpr { return be.node_str() }
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
		BoundIndexExpr { return be.str() }
		BoundErrorExpr { return be.str() }
		BoundCallExpr { return be.str() }
		BoundConvExpr { return be.str() }
		BoundNoneExpr { return be.str() }
		BoundStructInitExpr { return be.str() }
		BoundArrayInitExpr { return be.str() }
		NoneExpr { return be.str() }
	}
}

pub fn (be BoundExpr) to_ref_type() BoundExpr {
	match be {
		BoundLiteralExpr { return be.to_ref_type() }
		BoundUnaryExpr { return be.to_ref_type() }
		BoundBinaryExpr { return be.to_ref_type() }
		BoundVariableExpr { return be.to_ref_type() }
		BoundAssignExpr { return be.to_ref_type() }
		BoundIfExpr { return be.to_ref_type() }
		BoundRangeExpr { return be.to_ref_type() }
		BoundIndexExpr { return be.to_ref_type() }
		BoundErrorExpr { return be.to_ref_type() }
		BoundCallExpr { return be.to_ref_type() }
		BoundConvExpr { return be.to_ref_type() }
		BoundNoneExpr { return be.to_ref_type() }
		BoundStructInitExpr { return be.to_ref_type() }
		BoundArrayInitExpr { return be.to_ref_type() }
		NoneExpr { return be.to_ref_type() }
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
		BoundModuleStmt { return bs.node_str() }
		BoundImportStmt { return bs.node_str() }
		BoundAssertStmt { return bs.node_str() }
	}
}

pub fn (bs BoundStmt) str() string {
	match bs {
		BoundBlockStmt { return bs.str() }
		BoundExprStmt { return bs.str() }
		BoundForRangeStmt { return bs.str() }
		BoundForStmt { return bs.str() }
		BoundIfStmt { return bs.str() }
		BoundVarDeclStmt { return bs.str() }
		BoundGotoStmt { return bs.str() }
		BoundCondGotoStmt { return bs.str() }
		BoundLabelStmt { return bs.str() }
		BoundBreakStmt { return bs.str() }
		BoundContinueStmt { return bs.str() }
		BoundReturnStmt { return bs.str() }
		BoundCommentStmt { return bs.str() }
		BoundModuleStmt { return bs.str() }
		BoundImportStmt { return bs.str() }
		BoundAssertStmt { return bs.str() }
	}
}
