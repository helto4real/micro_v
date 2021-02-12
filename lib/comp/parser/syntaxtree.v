module parser

import lib.comp.ast
import lib.comp.token
import lib.comp.util

pub struct SyntaxTree {
pub:
	root      ast.Expression
	eof_token token.Token
	errors    []util.Message
}

fn new_syntax_tree(errors []util.Message, root ast.Expression, eof_token token.Token) SyntaxTree {
	return SyntaxTree{
		root: root
		eof_token: eof_token
		errors: errors
	}
}
