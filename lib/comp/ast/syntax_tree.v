module ast

import os
import lib.comp.util.source as src

[heap]
pub struct SyntaxTree {
pub:
	source &src.SourceText // represents source code
pub mut:
	log     &src.Diagnostics // errors when parsing
	root    CompNode
	mod     string
	imports []ImportStmt // imports of the file
}

pub fn new_syntax_tree(text string) &SyntaxTree {
	source := src.new_source_text_from_file(text, '')
	log := src.new_diagonistics()
	return &SyntaxTree{
		log: log
		source: source
	}
}

pub fn new_syntax_tree_from_file(filename string) ?&SyntaxTree {
	text := os.read_file(filename) ?
	source := src.new_source_text_from_file(text, filename)
	log := src.new_diagonistics()
	return &SyntaxTree{
		log: log
		source: source
	}
}

pub fn (t SyntaxTree) str() string {
	return '<syntax tree>'
}
