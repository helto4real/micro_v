module ast

// SyntaxKind has all kinds of syntax nodes in the AST
// 		This is an optimization to check for kinds
//		rather than check for type of each node
enum SyntaxKind {
	literal_expr
	name_expr
	unary_expr
	binary_expr
	para_expr
	assign_expr
	range_expr
	if_expr
	call_expr
	struct_init_expr
	array_init_expr
	index_expr
	empty_expr
	// nodes
	operator_node
	else_node
	else_expr_node
	comp_node
	syntax_type
	param_node
	type_node
	fn_decl_node
	comment_stmt
	module_stmt
	struct_decl_node
	struct_mbr_node
	struct_init_mbr_node
	call_arg_node
	// statements
	block_stmt
	break_stmt
	continue_stmt
	global_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	return_stmt
	for_range_stmt
	assert_stmt
	empty
	// syntax_helpers
}
