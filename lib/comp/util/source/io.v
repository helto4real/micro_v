module source

import term
import strings

pub struct SourceWriter {
mut:
	current_indent int
	builder        strings.Builder = strings.new_builder(0)
	write_indent   bool = true
}

pub fn (mut i SourceWriter) str() string {
	return i.builder.str()
}

pub fn (mut i SourceWriter) indent() int {
	return i.current_indent
}

pub fn (mut i SourceWriter) write_keyword(s string) {
	i.write_indent()
	i.builder.write_string(term.magenta(s))
}

pub fn (mut i SourceWriter) write_comment(s string) {
	i.write_indent()
	i.builder.write_string(term.green(s))
}

pub fn (mut i SourceWriter) write_string(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_green(s))
}

pub fn (mut i SourceWriter) write_number(s string) {
	i.write_indent()
	i.builder.write_string(term.rgb(146, 140, 0, s))
}

pub fn (mut i SourceWriter) write_identifier(s string) {
	i.write_indent()
	i.builder.write_string(term.bright_blue(s))
}

pub fn (mut i SourceWriter) write_punctuation(s string) {
	i.write_indent()
	i.builder.write_string(term.gray(s))
}

pub fn (mut i SourceWriter) write_space() {
	i.write_indent()
	i.builder.write_string(' ')
}

pub fn (mut i SourceWriter) writeln(s string) {
	i.write_indent()
	i.builder.writeln(s)
	i.write_indent = true
}

pub fn (mut i SourceWriter) write(s string) {
	i.write_indent()
	i.builder.write_string(s)
}

pub fn (mut i SourceWriter) indent_add(n int) {
	i.current_indent = i.current_indent + n
}

[inline]
fn (mut i SourceWriter) write_indent() {
	if i.write_indent && i.current_indent > 0 {
		i.builder.write_string('  '.repeat(i.current_indent))
		i.write_indent = false
	}
}
