module ast

import lib.comp.token
import lib.comp.util

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
	mut child_nodes := [AstNode(open_brace_token)]
	for i, _ in statements {
		child_nodes << statements[i]
	}
	child_nodes << close_brace_token
	return BlockStatementSyntax{
		open_brace_token: open_brace_token
		statements: statements
		close_brace_token: close_brace_token
		child_nodes: child_nodes
	}
}

pub fn (bs &BlockStatementSyntax) child_nodes() []AstNode {
	return bs.child_nodes
}
