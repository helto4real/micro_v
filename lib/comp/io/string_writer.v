module io

import strings

struct StringWriter {
mut:
	sb strings.Builder = strings.new_builder(0)
}

pub fn new_string_writer() StringWriter {
	return StringWriter{}
}

pub fn (mut sw StringWriter) writeln(s string) {
	sw.sb.writeln(s)
}

pub fn (mut sw StringWriter) write_string(s string) {
	sw.sb.write_string(s)
}
