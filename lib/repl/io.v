module repl

import term
import strings
import lib.comp.binding
// import lib.co'mp.util
// import lib.comp.parser

pub struct IdentWriter {
mut:
	current_indent int
	builder        strings.Builder = strings.new_builder(0)
	write_indent   bool = true
}

pub fn get_bound_node_string(node binding.BoundNode) string {
	mut iw := IdentWriter{}
	binding.write_node(iw, node)
	return iw.builder.str()
}

pub fn (mut i IdentWriter) str() string {
	return i.builder.str()
}

pub fn (mut i IdentWriter) indent() int {
	return i.current_indent
}

pub fn (mut i IdentWriter) write_keyword(s string) {
	i.write_indent()
	i.builder.write_string(term.magenta(s))
}

pub fn (mut i IdentWriter) write_comment(s string) {
	i.write_indent()
	i.builder.write_string(term.green(s))
}

pub fn (mut i IdentWriter) write_string(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_green(s))
}

pub fn (mut i IdentWriter) write_number(s string) {
	i.write_indent()
	i.builder.write_string(term.rgb(146, 140, 0, s))
}

pub fn (mut i IdentWriter) write_identifier(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_blue(s))
}

pub fn (mut i IdentWriter) write_punctuation(s string) {
	i.write_indent()
	i.builder.write_string(term.gray(s))
}

pub fn (mut i IdentWriter) write_space() {
	i.write_indent()
	i.builder.write_string(' ')
}

pub fn (mut i IdentWriter) writeln(s string) {
	i.write_indent()
	i.builder.writeln(s)
	i.write_indent = true
}

pub fn (mut i IdentWriter) write(s string) {
	i.write_indent()
	i.builder.write_string(s)
}

pub fn (mut i IdentWriter) indent_add(n int) {
	i.current_indent = i.current_indent + n
}

// pub fn (mut i IdentWriter) write_diagnostics(diagnostics []&source.Diagnostic, syntax_tree ast.SyntaxTree)  {
// 	// for err in diagnostics {
// 	// 	src := syntax_tree.source.str()
// 	// 	line_nr := syntax_tree.source.line_nr(err.pos.pos)
// 	// 	prefix := src[0..err.pos.pos]
// 	// 	mut err_end_pos := err.pos.pos + err.pos.len
// 	// 	if err_end_pos > src.len {
// 	// 		err_end_pos = src.len
// 	// 	}
// 	// 	error := src[err.pos.pos..err_end_pos]

// 	// 	postfix := if err_end_pos + err.pos.len < src.len {
// 	// 		src[err.pos.pos + err.pos.len..]
// 	// 	} else {
// 	// 		''
// 	// 	}

// 	// 	i.writeln(term.red(err.text))
// 	// 	i.writeln('')
// 	// 	i.write_string('$line_nr| ')
// 	// 	i.write_string(prefix.trim('\r\n'))
// 	// 	i.write_string(term.red(error))
// 	// 	i.writeln(postfix)
// 	// 	i.writeln('')
// 	// }
// }

[inline]
fn (mut i IdentWriter) write_indent() {
	if i.write_indent && i.current_indent > 0 {
		i.builder.write_string('  '.repeat(i.current_indent))
		i.write_indent = false
	}
}
