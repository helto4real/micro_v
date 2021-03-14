module source

import lib.comp.util.source

// SourceCode handles the source handling features
// 	- linenumber and columns
//	- formatting of errors
pub struct SourceText {
	text string
pub:
	filename string
pub mut:
	lines []TextLine
}

pub fn new_source_text_from_file(text string, filename string) &SourceText {
	return &source.SourceText{
		text: text
		filename: filename
	}
}

pub fn new_source_text(text string) &SourceText {
	return &source.SourceText{
		text: text
	}
}

// line_nr, returns line number for current positio
pub fn (s SourceText) line_nr(pos int) int {
	// use binary search for line number
	mut lower := 0
	mut upper := s.lines.len - 1
	for lower <= upper {
		index := lower + (upper - lower) / 2
		start := s.lines[index].start
		if pos == start {
			return index + 1
		}
		if start > pos {
			upper = index - 1
		} else {
			lower = index + 1
		}
	}
	return lower
}

pub fn (s &SourceText) str() string {
	return s.text
}

[inline]
pub fn (s &SourceText) str_range(start int, end int) string {
	return s.text[start..end]
}

[inline]
pub fn (s &SourceText) str_pos(pos Pos) string {
	return s.text[pos.pos..pos.pos + pos.len]
}

pub fn (mut s SourceText) add_line(start_pos int, end_pos int, lb_len int) {
	s.lines << new_text_line(s, start_pos, end_pos - start_pos + 1, lb_len)
}

[inline]
pub fn (s &SourceText) at(pos int) byte {
	return if pos < s.text.len { s.text[pos] } else { `\0` }
}

pub struct TextLine {
	source &SourceText
pub:
	start  int
	len    int
	lb_len int
}

fn new_text_line(source_text &SourceText, start int, len int, lb_len int) TextLine {
	return source.TextLine{
		source: source_text
		start: start
		len: len
		lb_len: lb_len
	}
}

pub fn (tl TextLine) pos() Pos {
	return source.new_pos(tl.start, tl.len)
}

pub fn (tl TextLine) pos_include_linebreak() Pos {
	return source.new_pos(tl.start, tl.len + tl.lb_len)
}

pub fn (tl TextLine) str() string {
	return tl.source.str_range(tl.start, tl.start + tl.len)
}
