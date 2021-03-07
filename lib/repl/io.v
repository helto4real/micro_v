module repl

import term
import strings
import lib.comp.binding

struct IdentWriter {
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

fn (mut i IdentWriter) str() string {
	return i.builder.str()
}

fn (mut i IdentWriter) indent() int {
	return i.current_indent
}

fn (mut i IdentWriter) write_keyword(s string) {
	i.write_indent()
	i.builder.write_string(term.magenta(s))
}

fn (mut i IdentWriter) write_string(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_green(s))
}

fn (mut i IdentWriter) write_number(s string) {
	i.write_indent()
	i.builder.write_string(term.rgb(146, 140, 0, s))
}

fn (mut i IdentWriter) write_identifier(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_blue(s))
}

fn (mut i IdentWriter) write_punctuation(s string) {
	i.write_indent()
	i.builder.write_string(term.gray(s))
}

fn (mut i IdentWriter) write_space() {
	i.write_indent()
	i.builder.write_string(' ')
}

fn (mut i IdentWriter) writeln(s string) {
	i.write_indent()
	i.builder.writeln(s)
	i.write_indent = true
}

fn (mut i IdentWriter) write(s string) {
	i.write_indent()
	i.builder.write_string(s)
}

fn (mut i IdentWriter) indent_add(n int) {
	i.current_indent = i.current_indent + n
}

[inline]
fn (mut i IdentWriter) write_indent() {
	if i.write_indent && i.current_indent > 0 {
		i.builder.write_string('  '.repeat(i.current_indent))
		i.write_indent = false
	}
}
