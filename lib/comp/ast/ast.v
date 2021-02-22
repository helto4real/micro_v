module ast

import lib.comp.token
import lib.comp.util

// pub struct EmptyExpr {
// pub:
// 	kind SyntaxKind = .empty
// 	pos  util.Pos
// }

// pub fn (ee &EmptyExpr) child_nodes() []AstNode {
// 	return []AstNode{}
// }

pub struct ComplationSyntax {
pub:
	kind        SyntaxKind = .comp_node
	eof_tok     token.Token
	pos         util.Pos
	stmt        StatementSyntax
	child_nodes []AstNode
}

pub fn new_comp_syntax(stmt StatementSyntax, eof_tok token.Token) ComplationSyntax {
	return ComplationSyntax{
		pos: stmt.pos()
		stmt: stmt
		eof_tok: eof_tok
		child_nodes: [AstNode(stmt)]
	}
}
pub fn (cn &ComplationSyntax) child_nodes() []AstNode {
	return cn.child_nodes
}
