module source

struct TextLocation {
pub:
	source &SourceText
	pos    Pos
}

pub fn new_text_location(source &SourceText, pos Pos) TextLocation {
	return TextLocation{
		source: source
		pos: pos
	}
}

pub fn (tl TextLocation) start_line() int {
	return tl.source.line_nr(tl.pos.pos)
}

pub fn (tl TextLocation) end_line() int {
	return tl.source.line_nr(tl.pos.pos + tl.pos.len)
}

pub fn (tl TextLocation) start_character() int {
	return tl.pos.pos - tl.source.lines[tl.start_line() - 1].start
}

pub fn (tl TextLocation) end_character() int {
	return tl.pos.pos + tl.pos.len - tl.source.lines[tl.start_line() - 1].start
}