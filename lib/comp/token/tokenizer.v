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
	start  int  // start of the token
	ln     int = 1 // current line being parsed
	len    int  // current parsed token len
	col    int  = 1 // current colum being parsed
	ch     byte = `\0` // current char
	is_eof bool
	kind   Kind // current token kind
pub mut:
	log util.Diagnostics // errors when tokenizing
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(text string) &Tokenizer {
	if text.len > 0 {
	}
	return &Tokenizer{
		text: text
		ch: if text.len > 0 { text[0] } else { `\0` }
		is_eof: if text.len > 0 { false } else { true }
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
	t.start = t.pos

	// Check for identifiers and keyword identifiers

	match t.ch {
		`(` {
			t.kind = .lpar
			t.next()
		}
		`)` {
			t.kind = .rpar
			t.next()
		}
		`{` {
			t.kind = .lcbr
			t.next()
		}
		`}` {
			t.kind = .rcbr
			t.next()
		}
		`+` {
			t.kind = .plus
			t.next()
		}
		`-` {
			t.kind = .minus
			t.next()
		}
		`*` {
			t.kind = .mul
			t.next()
		}
		`/` {
			t.kind = .div
			t.next()
		}
		token.single_quote, token.double_quote {
			t.read_string_literal()
		}
		`:` {
			t.next()
			if t.ch == `=` {
				t.kind = .colon_eq
				t.next()
			} else {
				t.kind = .colon
			}
		}
		`=` {
			t.next()
			if t.ch == `=` {
				t.kind = .eq_eq
				t.next()
			} else {
				t.kind = .eq
			}
		}
		`;` {
			t.kind = .semcol
			t.next()
		}
		`.` {
			t.kind = .dot
			t.next()
		}
		`!` {
			t.next()
			if t.ch == `=` {
				t.kind = .exl_mark_eq
				t.next()
			} else {
				t.kind = .exl_mark
			}
		}
		`&` {
			t.next()
			if t.ch == `&` {
				t.kind = .amp_amp
				t.next()
			} else {
				t.kind = .amp
			}
		}
		`|` {
			t.next()
			if t.ch == `|` {
				t.kind = .pipe_pipe
				t.next()
			} else {
				t.kind = .pipe
			}
		}
		`,` {
			t.kind = .comma
			t.next()
		}
		`\0` {
			t.kind = .eof
			t.next()
		}
		`0`...`9` {
			t.read_number_literal()
		}
		`a`...`z`, `A`...`Z`, `_` {
			t.read_identifier_or_keyword()
		}
		else {
			t.log.error_unexpected('token', t.ch.ascii_str(), t.pos())
			t.next()
			t.kind = .error
		}
	}

	len := t.pos - t.start
	mut text := token_str[t.kind] or {
		panic('compiler error, tokenkind: $t.kind not found in tokenlist')
	}
	if text == '' {
		// variable token lenght
		text = t.text[t.start..t.pos]
	}
	return t.token(t.kind, t.start, text, len)
}

// token instance new token of a kind
[inline]
fn (mut t Tokenizer) token(kind Kind, pos int, lit string, len int) Token {
	tok := Token{
		kind: kind
		lit: lit
		pos: util.Pos{
			pos: pos
			len: len
			ln: t.ln
			col: t.col
		}
	}

	return tok
}

// next, get next char
[inline]
fn (mut t Tokenizer) next() {
	t.pos++
	t.col++
	if t.pos >= t.text.len {
		t.is_eof = true
		t.ch = `\0`
		return
	}
	t.ch = t.text[t.pos]
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
	for t.ch != `\0` && t.ch.is_space() {
		if t.ch == `\r` {
			// Count \r\n as one line
			if t.peek(1) == `\n` {
				t.next()
				t.inc_line_nr()
			}
		} else if t.peek(0) == `\n` {
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
fn (mut t Tokenizer) read_identifier_or_keyword() {
	t.next()
	for t.ch != `\0` && (is_name_char(t.ch) || t.ch.is_digit()) {
		t.next()
	}
	name := t.text[t.start..t.pos]
	kind := keywords[name]
	if kind == .unknown {
		t.kind = .name
	} else {
		t.kind = kind
	}
}

// pos, returns current position
[inline]
fn (mut t Tokenizer) pos() util.Pos {
	return util.new_pos(t.pos, t.len, t.ln, t.col)
}

// read_string_literal returns a string literal
fn (mut t Tokenizer) read_string_literal() {
	t.kind = .string
	q_char := t.ch
	t.next()
	for {
		if t.ch == `\0` {
			t.log.error('unfinished string literal', t.pos())
			return
		}
		if t.ch == q_char {
			t.next()
			return
		}
		t.next()
	}
}

// name, gets the number token
[inline]
fn (mut t Tokenizer) read_number_literal() {
	for t.ch != `\0` && t.ch.is_digit() {
		t.next()
	}
	t.kind = .number
}

// is_nl returns true if character is new line
[inline]
pub fn is_nl(c byte) bool {
	return c == `\r` || c == `\n`
}
