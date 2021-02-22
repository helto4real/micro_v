module ast

import lib.comp.util

pub struct ExpressionStatementSyntax {
pub:
	// Node
	kind        SyntaxKind = .expr_stmt
	child_nodes []AstNode
	pos         util.Pos
	expr        ExpressionSyntax
}

pub fn new_expr_stmt_syntax(expr ExpressionSyntax) ExpressionStatementSyntax {
	return ExpressionStatementSyntax{
		expr: expr
		child_nodes: [AstNode(expr)]
	}
}

pub fn (bs &ExpressionStatementSyntax) child_nodes() []AstNode {
	return bs.child_nodes
}
