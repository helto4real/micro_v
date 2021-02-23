module parser

import lib.comp.ast
import lib.comp.util

pub struct SyntaxTree {
pub:
	source &util.SourceText // represents source code
	root   ast.CompExpr
	log    &util.Diagnostics // errors when parsing
}

// source &util.SourceText, log &util.Diagnostics, root ast.CompExpr
fn new_syntax_tree(text string) SyntaxTree {
	mut parser := new_parser_from_text(text)
	root := parser.parse_comp_node()
	return SyntaxTree{
		root: root
		log: parser.log
		source: parser.source
	}
}

pub fn parse_syntax_tree(text string) SyntaxTree {
	return new_syntax_tree(text)
}
