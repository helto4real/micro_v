module ast

// SyntaxKind has all kinds of syntax nodes in the AST
// 		This is an optimization to check for kinds
//		rather than check for type of each node
enum SyntaxKind {
	literal_expr
	binary_expr
	para_expr
	operator_node
}