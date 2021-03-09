module io

import strings

struct NodeStringWriter {
mut: 
	b strings.Builder = strings.new_builder(0)
}

pub fn new_node_string_writer() NodeStringWriter {
	return NodeStringWriter{

	}
}

pub fn  (mut w NodeStringWriter) str() string {
	return w.b.str()
}


pub fn (mut w NodeStringWriter) write_keyword(s string) {
	w.b.write_string(s)
}
pub fn (mut w NodeStringWriter) write_string(s string) {
	w.b.write_string(s)

}
pub fn (mut w NodeStringWriter) write_identifier(s string) {
	w.b.write_string(s)

}
pub fn (mut w NodeStringWriter) write_punctuation(s string) {
	w.b.write_string(s)

}
pub fn (mut w NodeStringWriter) write_number(s string) {
	w.b.write_string(s)

}
pub fn (mut w NodeStringWriter) write_space() {
	w.b.write_string(' ')

}
pub fn (mut w NodeStringWriter) writeln(s string) {
	w.b.writeln(s)

}
pub fn (mut w NodeStringWriter) write(s string) {
	w.b.write_string(s)

}
pub fn (mut w NodeStringWriter) indent_add(n int) {

}
pub fn (mut w NodeStringWriter) indent() int {
	return 0
}