module token

import lib.comp.util

const (
	single_quote = `\'`
	double_quote = `"`
)

pub struct Tokenizer {
	text string // text tokenized
mut:
	pos    int  // current position in file
	ln     int  = 1 // current line being parsed
	col    int  = 1 // current colum being parsed
	ch     byte = `\0` // current char
	is_eof bool
pub mut:
	errors []util.Message // errors when tokenizing
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(text string) &Tokenizer {
	if text.len > 0 {
	}
	return &Tokenizer{
		text: text
		ch: if text.len > 0 {
			text[0]
		} else {
			`\0`
		}
		is_eof: if text.len > 0 {
			false
		} else {
			true
		}
	}
}

pub fn (mut t Tokenizer) scan_all() []Token {
	mut tokens := []Token{}
	for {
		mut tok := t.next_token()
		tokens << tok
		if tok.kind == .eof {
			break
		}
	}
	return tokens
}

// scans next token from text
pub fn (mut t Tokenizer) next_token() Token {
	// whitepace has no meaning and will exl_mark be parsed
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
		number := t.number_literal()
		return t.token(.number, number, number.len)
	}
	match t.ch {
		`(` {
			return t.token(.lpar, '(', 1)
		}
		`)` {
			return t.token(.rpar, ')', 1)
		}
		`{` {
			return t.token(.lcbr, '{', 1)
		}
		`}` {
			return t.token(.rcbr, '}', 1)
		}
		`+` {
			return t.token(.plus, '+', 1)
		}
		`-` {
			return t.token(.minus, '-', 1)
		}
		`*` {
			return t.token(.mul, '*', 1)
		}
		`/` {
			return t.token(.div, '/', 1)
		}
		token.single_quote, token.double_quote {
			ident_string := t.string_literal()
			return t.token(.string, ident_string, ident_string.len)
		}
		`:` {
			if nextc == `=` {
				return t.token(.decl_assign, ':=', 2)
			} else {
				return t.token(.colon, ':', 1)
			}
		}
		`=` {
			if nextc == `=` {
				return t.token(.eq_eq, '==', 2)
			}
			return t.token(.eq, '=', 1)
		}
		`;` {
			return t.token(.semcol, ';', 1)
		}
		`.` {
			return t.token(.dot, '.', 1)
		}
		`!` {
			if nextc == `=` {
				return t.token(.exl_mark_eq, '!=', 2)
			}
			return t.token(.exl_mark, '!', 1)
		}
		`&` {
			if nextc == `&` {
				return t.token(.amp_amp, '&&', 2)
			}
			return t.token(.amp, '&', 1)
		}
		`|` {
			if nextc == `|` {
				return t.token(.pipe_pipe, '||', 2)
			}
			return t.token(.pipe, '|', 1)
		}
		`,` {
			return t.token(.comma, ',', 1)
		}
		else {
			t.error('unexpected token: $t.ch.ascii_str()')
			return t.token(.error, '$t.ch.ascii_str()', 1)
		}
	}

	t.error('unexpected token: $t.ch.ascii_str()')
	return t.token(.error, '$t.ch.ascii_str()', 1)
}

// token instance new token of a kind
[inline]
fn (mut t Tokenizer) token(kind Kind, lit string, len int) Token {
	tok := Token{
		kind: kind
		lit: lit
		pos: util.Pos{
			pos: t.pos
			ln: t.ln
			col: t.col
		}
	}
	t.skip(len)

	return tok
}

// next, get next char
[inline]
fn (mut t Tokenizer) next() {
	if t.is_eof {
		return
	}
	t.pos++
	t.col++
	if t.pos >= t.text.len {
		t.is_eof = true
		t.ch = `\0`
		return
	}
	t.ch = t.text[t.pos]
}

// skip, skips n chars
[inline]
fn (mut t Tokenizer) skip(n int) {
	if t.pos + n < t.text.len {
		t.pos += n
		t.col += n
		t.ch = t.text[t.pos]
	} else {
		t.col += n
		t.is_eof = true
		t.ch = `\0`
		if t.pos + n > t.text.len + 1 {
			t.error('skipping character pos out of scope: $t.pos, $n ($t.text.len)')
		}
		t.pos = t.text.len
	}
}

// peek, peeks the character at pos + n or '\0' if eof
[inline]
fn (mut t Tokenizer) peek(n int) byte {
	if t.pos + n < t.text.len {
		return t.text[t.pos + n]
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
		} else if t.ch == `\n` {
			t.inc_line_nr()
		}
		t.next()
	}
}

// inc_line_nr, increments line number
[inline]
fn (mut t Tokenizer) inc_line_nr() {
	t.ln++
	t.col = 0
}

// is_name_char returns true if character is in a name
[inline]
pub fn is_name_char(c byte) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

// name, gets the name token
fn (mut t Tokenizer) name_tok() string {
	start := t.pos
	mut len := 1
	mut peek := t.peek(len)
	for peek != `\0` && (is_name_char(peek) || peek.is_digit()) {
		len++
		peek = t.peek(len)
	}
	return t.text[start..(start + len)]
}

// string_literal returns a string literal
fn (mut t Tokenizer) string_literal() string {
	start_pos := t.pos + 1
	mut len := 1
	mut peek := t.peek(len)
	q_char := t.ch
	for {
		if peek == `\0` {
			t.error('unfinished string literal')
			break
		}
		if peek == q_char {
			if len > 1 {
				return t.text[start_pos..start_pos + len - 1]
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
fn (mut t Tokenizer) number_literal() string {
	start := t.pos
	mut len := 1
	mut peek := t.peek(len)
	for peek != `\0` && peek.is_digit() {
		len++
		peek = t.peek(len)
	}
	return t.text[start..(start + len)]
}

// is_nl returns true if character is new line
[inline]
pub fn is_nl(c byte) bool {
	return c == `\r` || c == `\n`
}
