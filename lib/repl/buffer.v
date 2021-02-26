module repl

import strings

struct Buffer {
	tab_width int = 4
pub mut:
	lines  []string
	cursor Cursor
}

fn (mut b Buffer) move_updown(amount int) {
	b.cursor.move(0, amount)
	// Check the move
	line := b.cur_line()
	if b.cursor.pos_x > line.len {
		b.cursor.set(line.len, b.cursor.pos_y)
	}
}

fn (b Buffer) cur_line() string {
	return b.line(b.cursor.pos_y)
}

fn (mut b Buffer) del(amount int) string {
	if amount == 0 {
		return ''
	}
	x, y := b.cursor.xy()
	if amount < 0 { // don't delete left if we're at 0,0
		if x == 0 && y == 0 {
			return ''
		}
	} else if x >= b.cur_line().len && y >= b.lines.len - 1 {
		return ''
	}
	mut removed := ''
	if amount < 0 { // backspace (backward)
		i := b.cursor_index()
		removed = b.raw()[i + amount..i]
		mut left := amount * -1
		for li := y; li >= 0 && left > 0; li-- {
			ln := b.lines[li]
			if left > ln.len {
				b.lines.delete(li)
				if ln.len == 0 { // line break delimiter
					left--
					if y == 0 {
						return ''
					}
					line_above := b.lines[li - 1]
					b.cursor.pos_x = line_above.len
				} else {
					left -= ln.len
				}
				b.cursor.pos_y--
			} else {
				if x == 0 {
					if y == 0 {
						return ''
					}
					line_above := b.lines[li - 1]
					if ln.len == 0 { // at line break
						b.lines.delete(li)
						b.cursor.pos_y--
						b.cursor.pos_x = line_above.len
					} else {
						b.lines[li - 1] = line_above + ln
						b.lines.delete(li)
						b.cursor.pos_y--
						b.cursor.pos_x = line_above.len
					}
				} else if x == 1 {
					b.lines[li] = b.lines[li][left..]
					b.cursor.pos_x = 0
				} else {
					b.lines[li] = ln[..x - left] + ln[x..]
					b.cursor.pos_x -= left
				}
				left = 0
				break
			}
		}
	} else { // delete (forward)
		i := b.cursor_index() + 1
		removed = b.raw()[i - amount..i]
		mut left := amount
		for li := y; li >= 0 && left > 0; li++ {
			ln := b.lines[li]
			if x == ln.len { // at line end
				if y + 1 <= b.lines.len {
					b.lines[li] = ln + b.lines[y + 1]
					b.lines.delete(y + 1)
					left--
					b.del(left)
				}
			} else if left > ln.len {
				b.lines.delete(li)
				left -= ln.len
			} else {
				b.lines[li] = ln[..x] + ln[x + left..]
				left = 0
			}
		}
	}
	$if debug {
		flat := removed.replace('\n', r'\n')
		eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' "$flat"')
	}
	return removed
}

fn (b Buffer) flat() string {
	return b.raw().replace_each(['\n', r'\n', '\t', r'\t'])
}

fn (b Buffer) raw() string {
	return b.lines.join('\n')
}

fn (b Buffer) line(i int) string {
	if i < 0 || i >= b.lines.len {
		return ''
	}
	return b.lines[i]
}

fn (b Buffer) cursor_index() int {
	mut i := 0
	for y, line in b.lines {
		if b.cursor.pos_y == y {
			i += b.cursor.pos_x
			break
		}
		i += line.len + 1
	}
	return i
}
fn (mut b Buffer) put(s string) {
	has_line_ending := s.contains('\n')
	x, y := b.cursor.xy()
	if b.lines.len == 0 {
		b.lines.prepend('')
	}
	line := b.lines[y]
	l, r := line[..x], line[x..]
	if has_line_ending {
		mut lines := s.split('\n')
		lines[0] = l + lines[0]
		lines[lines.len - 1] += r
		b.lines.delete(y)
		b.lines.insert(y, lines)
		last := lines[lines.len - 1]
		b.cursor.set(last.len, y + lines.len - 1)
		if s == '\n' {
			b.cursor.set(0, b.cursor.pos_y)
		}
	} else {
		b.lines[y] = l + s + r
		b.cursor.set(x + s.len, y)
	}
	$if debug {
		flat := s.replace('\n', r'\n')
		eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' "$flat"')
	}
}

// move_cursor will navigate the cursor within the buffer bounds
fn (mut b Buffer) move_cursor(amount int, movement Movement) {
	cur_line := b.cur_line()
	match movement {
		.up {
			if b.cursor.pos_y - amount >= 0 {
				b.move_updown(-amount)
			}
		}
		.down {
			if b.cursor.pos_y + amount < b.lines.len {
				b.move_updown(amount)
			}
		}
		.page_up {
			dlines := imin(b.cursor.pos_y, amount)
			b.move_updown(-dlines)
		}
		.page_down {
			dlines := imin(b.lines.len - 1, b.cursor.pos_y + amount) - b.cursor.pos_y
			b.move_updown(dlines)
		}
		.left {
			if b.cursor.pos_x - amount >= 0 {
				b.cursor.move(-amount, 0)
			} else if b.cursor.pos_y > 0 {
				b.cursor.set(b.line(b.cursor.pos_y - 1).len, b.cursor.pos_y - 1)
			}
		}
		.right {
			if b.cursor.pos_x + amount <= cur_line.len {
				b.cursor.move(amount, 0)
			} else if b.cursor.pos_y + 1 < b.lines.len {
				b.cursor.set(0, b.cursor.pos_y + 1)
			}
		}
		.home {
			b.cursor.set(0, b.cursor.pos_y)
		}
		.end {
			b.cursor.set(cur_line.len, b.cursor.pos_y)
		}
	}
}

fn (b Buffer) view(from int, to int) View {
	l := b.cur_line()
	mut x := 0
	for i := 0; i < b.cursor.pos_x && i < l.len; i++ {
		if l[i] == `\t` {
			x += b.tab_width
			continue
		}
		x++
	}
	mut lines := []string{}
	for i, line in b.lines {
		if i >= from && i <= to {
			lines << line
		}
	}
	raw := lines.join('\n')
	return {
		raw: raw.replace('\t', strings.repeat(` `, b.tab_width))
		cursor: {
			pos_x: x
			pos_y: b.cursor.pos_y
		}
	}
}
