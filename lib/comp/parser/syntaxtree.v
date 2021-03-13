module parser

import lib.comp.ast
import lib.comp.util.source

pub struct SyntaxTree {
pub:
	source   &source.SourceText // represents source code
	root     ast.CompNode
	log      &source.Diagnostics // errors when parsing
	filename string
}

// source &source.SourceText, log &source.Diagnostics, root ast.CompNode
fn new_syntax_tree(text string) SyntaxTree {
	mut parser := new_parser_from_text(text)
	root := parser.parse_comp_node()
	return SyntaxTree{
		root: root
		log: parser.log
		source: parser.source
	}
}

fn load_syntax_tree(filename string) ?SyntaxTree {
	mut parser := new_parser_from_file(filename) ?
	root := parser.parse_comp_node()
	return SyntaxTree{
		root: root
		log: parser.log
		source: parser.source
		filename: filename
	}
}

pub fn parse_syntax_tree(text string) SyntaxTree {
	return new_syntax_tree(text)
}

pub fn parse_syntax_tree_from_file(text string) ?SyntaxTree {
	return load_syntax_tree(text)
}
