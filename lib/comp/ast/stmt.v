module ast

import lib.comp.token
import lib.comp.util

type StatementSyntax = BlockStatementSyntax | ExpressionStatementSyntax

pub fn (ex &StatementSyntax) children() []AstNode {
	match ex {
		BlockStatementSyntax, ExpressionStatementSyntax {
			return ex.child_nodes()
		}

	}
}

pub fn (ex &StatementSyntax) pos() util.Pos {
	match ex {
		BlockStatementSyntax, ExpressionStatementSyntax {
			return ex.pos
		}
	}
}

pub struct BlockStatementSyntax {
pub:
	// Node
	kind              SyntaxKind = .block_stmt
	child_nodes       []AstNode
	pos               util.Pos
	open_brace_token  token.Token
	statements        []StatementSyntax
	close_brace_token token.Token
}

pub fn new_block_statement_syntax(open_brace_token token.Token, statements []StatementSyntax, close_brace_token token.Token) BlockStatementSyntax {
	// mut child_nodes := child_nodes: [AstNode(open_brace_token)]
	// for i, _ in statements {
	// 	child_nodes << statements[i]
	// }
	return BlockStatementSyntax{
		open_brace_token: open_brace_token
		statements: statements
		close_brace_token: close_brace_token
		// child_nodes: [open_brace_token, statements, close_brace_token]
	}
}

pub fn (bs &BlockStatementSyntax) child_nodes() []AstNode {
	return bs.child_nodes
}

pub struct ExpressionStatementSyntax {
pub:
	// Node
	kind              SyntaxKind = .expr_stmt
	child_nodes       []AstNode
	pos               util.Pos
	expr 			  ExpressionSyntax
}

pub fn new_expr_stmt_syntax(expr ExpressionSyntax) ExpressionStatementSyntax {
	// mut child_nodes := child_nodes: [AstNode(open_brace_token)]
	// for i, _ in statements {
	// 	child_nodes << statements[i]
	// }
	return ExpressionStatementSyntax{
		expr: expr
		// child_nodes: [open_brace_token, statements, close_brace_token]
	}
}

pub fn (bs &ExpressionStatementSyntax) child_nodes() []AstNode {
	return bs.child_nodes
}