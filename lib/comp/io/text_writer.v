module io

pub interface TermTextWriter {
	write_keyword(s string)
	write_string(s string)
	write_identifier(s string)
	write_punctuation(s string)
	write_number(s string)
	write_space()
	writeln(s string)
	write(s string)
	indent_add(n int)
	indent() int
}

pub interface TextWriter {
	writeln(s string) ?int
	write_string(s string) ?int
}