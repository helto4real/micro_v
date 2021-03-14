module util

import strings
import lib.comp.util.source

pub struct AnnotatedText {
pub:
	text  string
	posns []source.Pos
}

fn new_annotated_text(text string, posns []source.Pos) AnnotatedText {
	return AnnotatedText{
		text: text
		posns: posns
	}
}

pub fn parse_annotated_text(text string) AnnotatedText {
	mut b := strings.new_builder(20)
	uindent_text := unindent(text)
	mut posns := []source.Pos{cap: 20}
	mut fake_stack := []int{cap: 20}

	mut pos := 0
	for c in uindent_text {
		if c == `[` {
			fake_stack.prepend(pos)
		} else if c == `]` {
			if fake_stack.len == 0 {
				panic('unexpected error, missing "["?')
			}
			start := fake_stack.pop()
			end := pos
			posns << source.new_pos_from_bounds(start, end)
		} else {
			pos++
			b.write_b(c)
		}
	}

	if fake_stack.len > 0 {
		panic('unexpected error, missing "]"?')
	}

	return AnnotatedText{
		text: b.str()
		posns: posns
	}
}

pub fn unindent(text string) string {
	mut lines := unindent_lines(text)
	mut b := strings.new_builder(lines.len)
	for line in lines {
		if line == '' {
			continue
		}
		b.writeln(line)
	}
	return b.str()
}

pub fn unindent_lines(text string) []string {
	mut lines := text.split_into_lines()

	mut min_indent := int(0xfffffff) // some crazy big value
	for i, line in lines {
		if line.trim_space().len == 0 {
			lines[i] = ''
			continue
		}
		indent := line.len - line.trim_left(' \t').len
		min_indent = if indent < min_indent { indent } else { min_indent }
		lines[i] = line[min_indent..]
	}
	// trim start and end empty lines but keep in between
	for lines.len > 0 && lines[0].len == 0 {
		lines.delete(0)
	}
	for lines.len > 0 && lines[lines.len - 1].len == 0 {
		lines.delete(lines.len - 1)
	}
	return lines
}
