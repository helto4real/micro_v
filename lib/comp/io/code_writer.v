module io
import strings

pub interface CodeWriter {
	write_space()
	writeln(s string)
	write(s string)
	// write_diagnostics(diagnostics []&source.Diagnostic, syntax_tree ast.SyntaxTree) 
	indent_add(n int)
	indent() int
}

pub struct GeneralCodeWriter {
mut:
	current_indent int
	builder        strings.Builder = strings.new_builder(0)
	write_indent   bool = true
}
pub fn new_general_code_writer() GeneralCodeWriter {
	return GeneralCodeWriter {}
}
pub fn (mut gcw GeneralCodeWriter) write_space() {
	gcw.write(' ')
}
pub fn (mut gcw GeneralCodeWriter) writeln(s string) {
	gcw.write_indent()
	gcw.builder.writeln(s)
	gcw.write_indent = true
}
pub fn (mut gcw GeneralCodeWriter) write(s string) {
	gcw.write_indent()
	gcw.builder.write_string(s)
}

pub fn (mut gcw GeneralCodeWriter) indent_add(n int) {
	gcw.current_indent = gcw.current_indent + n
}
pub fn (mut gcw GeneralCodeWriter) indent() int {
	return gcw.current_indent
}

pub fn (mut gcw GeneralCodeWriter) str() string {
	return gcw.builder.str()
}

[inline]
fn (mut gcw GeneralCodeWriter) write_indent() {
	if gcw.write_indent && gcw.current_indent > 0 {
		gcw.builder.write_string('\t'.repeat(gcw.current_indent))
		gcw.write_indent = false
	}
}