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
	// nodes
	operator_node
	comp_node
	// statements
	block_stmt
	expr_stmt
	var_decl_stmt
	empty
}
