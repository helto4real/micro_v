import lib.comp.util

fn test_source_at() {
	source := util.new_source_text('abc')

	assert source.at(0) == `a`
	assert source.at(1) == `b`
	assert source.at(2) == `c`
	assert source.at(3) == `\0`
	assert source.at(4) == `\0`
}

fn test_source_range() {
	source := util.new_source_text('abc123')

	assert source.str_range(0, 2) == 'ab'
	assert source.str_range(3, 4) == '1'
}

fn text_line_parsing() {
	mut source := util.new_source_text('abc123\n321abc')

	source.add_line(0, 5, 1)

	assert source.lines.len == 2
	assert source.lines[0].str() == 'abc123'
	assert source.lines[1].str() == '321abc'
}

fn text_line_parsing_crln() {
	mut source := util.new_source_text('abc123\r\n321abc')

	source.add_line(0, 5, 2)

	assert source.lines.len == 2
	assert source.lines[0].str() == 'abc123'
	assert source.lines[1].str() == '321abc'
}

fn text_empty_line_parsing() {
	mut source := util.new_source_text('abc123\n')

	source.add_line(0, 5, 1)

	assert source.lines.len == 2
	assert source.lines[0].str() == 'abc123'
	assert source.lines[1].str() == ''
}

fn text_line_pos() {
	mut source := util.new_source_text('abc123\n321abc')

	source.add_line(0, 5, 1)

	assert source.lines.len == 2
	assert source.lines[0].pos().pos == 0
	assert source.lines[0].pos().len == 3
	assert source.lines[1].pos().pos == 6
	assert source.lines[1].pos().len == 3
}

fn test_line_pos_crln() {
	mut source := util.new_source_text('abc123\r\n321abc')

	source.add_line(0, 5, 2)
	source.add_line(8, 13, 0)

	assert source.lines.len == 2
	assert source.lines[0].pos().pos == 0
	assert source.lines[0].pos().len == 6
	assert source.lines[1].pos().pos == 8
	assert source.lines[1].pos().len == 6
}

fn test_text_line_nr() {
	mut source := util.new_source_text('abc123\r\n321abc\r\n123456')

	source.add_line(0, 5, 2)
	source.add_line(8, 13, 2)
	source.add_line(16, 21, 0)

	assert source.lines.len == 3
	assert source.line_nr(0) == 1
	assert source.line_nr(1) == 1
	assert source.line_nr(2) == 1
	assert source.line_nr(3) == 1
	assert source.line_nr(4) == 1
	assert source.line_nr(5) == 1
	assert source.line_nr(6) == 1
	assert source.line_nr(7) == 1
	assert source.line_nr(8) == 2
	assert source.line_nr(9) == 2
	assert source.line_nr(10) == 2
	assert source.line_nr(11) == 2
	assert source.line_nr(12) == 2
	assert source.line_nr(14) == 2
	assert source.line_nr(15) == 2
	assert source.line_nr(16) == 3
	assert source.line_nr(18) == 3
	assert source.line_nr(19) == 3
	assert source.line_nr(20) == 3
	assert source.line_nr(21) == 3
	assert source.line_nr(22) == 3
}
