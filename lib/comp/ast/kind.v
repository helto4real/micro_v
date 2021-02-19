module ast

// SyntaxKind has all kinds of syntax nodes in the AST
// 		This is an optimization to check for kinds
//		rather than check for type of each node
enum SyntaxKind {
	literal_expr
	binary_expr
	unary_expr
	para_expr
	name_expr
	assign_expr
	operator_node
	comp_node
	empty
}
