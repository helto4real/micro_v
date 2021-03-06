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
	// nodes
	operator_node
	else_node
	else_expr_node
	comp_node
	syntax_type
	node_param
	node_type
	node_fn_decl
	global_stmt
	// statements
	block_stmt
	expr_stmt
	var_decl_stmt
	if_stmt
	for_stmt
	for_range_stmt
	empty
	// syntax_helpers
}
