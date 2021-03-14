module ast

import os
import lib.comp.util.source as src

[heap]
pub struct SyntaxTree {
pub:
	source   &src.SourceText // represents source code
pub mut:
	log      &src.Diagnostics // errors when parsing
	root     CompNode
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

// pub fn new_syntax_tree(root CompNode, source &source.SourceText, log &source.Diagnostics) &SyntaxTree {
// 	return &SyntaxTree{
// 		root: root
// 		log: log
// 		source: source
// 	}
// }

// pub fn new_syntax_tree_from_file(root CompNode, source &source.SourceText, log &source.Diagnostics, filename string) &SyntaxTree {
// 	return &SyntaxTree{
// 		root: root
// 		log: log
// 		source: source
// 		filename: filename
// 	}
// }