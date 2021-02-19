module parser

import lib.comp.ast
import lib.comp.token
import lib.comp.util

pub struct SyntaxTree {
pub:
	source    &util.SourceText // represents source code
	root      ast.Expression
	eof_token token.Token
	log       &util.Diagnostics // errors when parsing
}

fn new_syntax_tree(source &util.SourceText, log &util.Diagnostics, root ast.Expression, eof_token token.Token) SyntaxTree {
	return SyntaxTree{
		root: root
		eof_token: eof_token
		log: log
		source: source
	}
}
