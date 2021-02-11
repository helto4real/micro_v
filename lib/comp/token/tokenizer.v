module token

const (
	single_quote = `\'`
	double_quote = `"`
)

pub struct Tokenizer {
	code string // code tokenized
mut:
	pos    int  // current position in file
	ln     int  = 1 // current line being parsed
	col    int  = 1 // current colum being parsed
	ch     byte = `\0` // current char
	is_eof bool
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(code string) &Tokenizer {
	if code.len > 0 {
	}
	return &Tokenizer{
		code: code
		ch: if code.len > 0 {
			code[0]
		} else {
			`\0`
		}
		is_eof: if code.len > 0 {
			false
		} else {
			true
		}
	}
}

// scans next token from code
pub fn (mut t Tokenizer) next_token() Token {
	// whitepace has no meaning and will not be parsed
	t.skip_whitespace()
	
	if t.is_eof {
		return t.token(.eof, 'eof', 1)
	}
	nextc := t.peek(1)

	// Check for identifiers and keyword identifiers
	if is_name_char(t.ch) {
		name := t.name_tok()
		kind := keywords[name]
		if kind == .unknown {
			return t.token(.name, name, name.len)
		} else {
			return t.token(kind, name, name.len)
		}
	} else if t.ch.is_digit() {
		number := t.number()
		return t.token(.number, number, number.len)
	} 
	match t.ch {
		`(` {
			t.token(.lpar, '(', 1)
		}
		`)` {
			t.token(.rpar, ')', 1)
		}
		`{` {
			t.token(.lcbr, '{', 1)
		}
		`}` {
			t.token(.rcbr, '}', 1)
		}
		single_quote, double_quote {
			ident_string := t.string_tok()
			return t.token(.string, ident_string, ident_string.len)
		}
		`:` {
			if nextc == `=` {
				return t.token(.decl_assign, ':=', 2)
			} else {
				return t.token(.colon, ':', 1)
			}
		}
		else {return t.token(.error, '$t.ch.ascii_str()', 1)}
	}
		// `=` {
		// 	if nextc == `=` {
		// 		s.pos++
		// 		return s.token_unknown() 
		// 	} else {
		// 		return s.token_assign()
		// 	}

		// }
		// `.` {
		// 	return s.token_dot()
		// }
		// `/` {
		// 	if nextc == `/` {
		// 		// Line comment
		// 		s.skip_comment(true)
		// 	} else if nextc == `*` {
		// 		// Normal comment
		// 		s.skip_comment(false)
		// 	} else {
		// 		s.token_div()
		// 	}
		// }
		// `&` {					
		// 	return s.token_amp()
		// }
		// else {
		// 	s.pos++
		// 	return s.token_unknown()
		// }

	return t.token(.error, '$t.ch.ascii_str()', 1)
}

// token instance new token of a kind
fn (mut t Tokenizer) token(kind Kind, lit string, len int) Token {
	tok := Token{
		kind: kind
		lit: lit
		pos: Pos{
			pos: t.pos
			ln: t.ln
			col: t.col
		}
	}
	t.skip(len)

	return tok
}

// next, get next char
fn (mut t Tokenizer) next() {
	if t.is_eof {
		return
	}
	t.pos++
	t.col++
	if t.pos >= t.code.len {
		t.is_eof = true
		t.ch = `\0`
		return
	}
	t.ch = t.code[t.pos]
}

// skip, skips n chars
fn (mut t Tokenizer) skip(n int) {
	if t.pos + n < t.code.len {
		t.pos += n
		t.col += n
		t.ch = t.code[t.pos]
	} else {
		t.col += n
		t.pos = t.code.len
		t.is_eof = true
		t.ch = `\0`
		// todo: error here
	}
}

// peek, peeks the character at pos + n or '\0' if eof
fn (mut t Tokenizer) peek(n int) byte {
	if t.pos + n < t.code.len {
		return t.code[t.pos + n]
	} else {
		return `\0`
	}
}

// skip_whitespace, skips all whitespace characters
fn (mut t Tokenizer) skip_whitespace() {
	for !t.is_eof && t.ch.is_space() {
		if t.ch == `\r` {
			// Count \r\n as one line
			if t.peek(1) == `\n` {
				t.next()
				t.inc_line_nr()
			}
		} else if t.ch == `\r` {
			t.inc_line_nr()
		}
		t.next()
	}
}

// inc_line_nr, increments line number
fn (mut t Tokenizer) inc_line_nr() {
	t.ln++
	t.col = 1
}

// is_name_char returns true if character is in a name
pub fn is_name_char(c byte) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

// name, gets the name token
fn (mut t Tokenizer) name_tok() string {
	start := t.pos
	mut len := 1
	mut peek := t.peek(len)
	for peek != `\0` && (is_name_char(peek) || peek.is_digit()) {
		peek = t.peek(len)
		len++
	}
	return t.code[start..(start + len - 1)]
}

fn (mut t Tokenizer) string_tok() string {
	start_pos := t.pos + 1
	mut len := 1
	mut peek := t.peek(len)
	q_char := t.ch
	for {
		if peek == `\0` {
			// Todo: fix error
			// s.error('unfinished string literal')
			break
		}
		if peek == q_char {
			if len>1 {
				return t.code[start_pos..start_pos+len-1]
			} else {
				return ''
			}
		}
		len++
		peek = t.peek(len)
	}
	return ''
}

// name, gets the number token
fn (mut t Tokenizer) number() string {
	start := t.pos
	mut len := 1
	mut peek := t.peek(len)
	for peek != `\0` && peek.is_digit() {
		peek = t.peek(len)
		len++
	}
	return t.code[start..(start + len - 1)]
}

// is_nl returns true if character is new line
pub fn is_nl(c byte) bool {
	return c == `\r` || c == `\n`
}
