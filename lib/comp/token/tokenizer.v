module token

import lib.comp.util

const (
	single_quote = `\'`
	double_quote = `"`
)

pub struct Tokenizer {
	text string // text tokenized
mut:
	source &util.SourceText // represents source code
	start_line_pos int
	pos    int  // current position in file
	start  int  // start of the token
	len    int  // current parsed token len
	ch     byte = `\0` // current char
	is_eof bool
	kind   Kind // current token kind
pub mut:
	log util.Diagnostics // errors when tokenizing
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(text string) &Tokenizer {
	source := util.new_source_text(text)
	return &Tokenizer{
		source: source
		ch: source.at(0)
	}
}

pub fn new_tokenizer_from_source(source &util.SourceText) &Tokenizer {
	return &Tokenizer{
		source: source
		ch: source.at(0)
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
	t.kind = .bad_token

	// Check for identifiers and keyword identifiers
	match t.ch {
		`(` {
			t.kind = .lpar
			t.incr_pos()
		}
		`)` {
			t.kind = .rpar
			t.incr_pos()
		}
		`{` {
			t.kind = .lcbr
			t.incr_pos()
		}
		`}` {
			t.kind = .rcbr
			t.incr_pos()
		}
		`+` {
			t.kind = .plus
			t.incr_pos()
		}
		`-` {
			t.kind = .minus
			t.incr_pos()
		}
		`*` {
			t.kind = .mul
			t.incr_pos()
		}
		`/` {
			t.kind = .div
			t.incr_pos()
		}
		token.single_quote, token.double_quote {
			t.read_string_literal()
		}
		`:` {
			t.incr_pos()
			if t.ch == `=` {
				t.kind = .colon_eq
				t.incr_pos()
			} else {
				t.kind = .colon
			}
		}
		`=` {
			t.incr_pos()
			if t.ch == `=` {
				t.kind = .eq_eq
				t.incr_pos()
			} else {
				t.kind = .eq
			}
		}
		`;` {
			t.kind = .semcol
			t.incr_pos()
		}
		`.` {
			t.kind = .dot
			t.incr_pos()
		}
		`!` {
			t.incr_pos()
			if t.ch == `=` {
				t.kind = .exl_mark_eq
				t.incr_pos()
			} else {
				t.kind = .exl_mark
			}
		}
		`&` {
			t.incr_pos()
			if t.ch == `&` {
				t.kind = .amp_amp
				t.incr_pos()
			} else {
				t.kind = .amp
			}
		}
		`|` {
			t.incr_pos()
			if t.ch == `|` {
				t.kind = .pipe_pipe
				t.incr_pos()
			} else {
				t.kind = .pipe
			}
		}
		`,` {
			t.kind = .comma
			t.incr_pos()
		}
		`\0` {
			t.kind = .eof
			t.incr_pos()
		}
		`0`...`9` {
			t.read_number_literal()
		}
		`a`...`z`, `A`...`Z`, `_` {
			t.read_identifier_or_keyword()
		}
		else {
			t.log.error_unexpected('token', t.ch.ascii_str(), t.token_pos())
			t.incr_pos()
		}
	}

	len := t.pos - t.start
	mut text := token_str[t.kind] or {
		panic('compiler error, tokenkind: $t.kind not found in tokenlist')
	}
	if text == '' {
		// variable token lenght
		text = t.source.str_range(t.start, t.pos)
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
		}
	}

	return tok
}

// next, get next char
[inline]
fn (mut t Tokenizer) incr_pos() {
	t.pos++
	t.ch = t.source.at(t.pos)
	if t.ch == `\0` {
		t.is_eof = true
		return
	}
}

// peek_pos, peeks the character at pos + n or '\0' if eof
[inline]
fn (mut t Tokenizer) peek_pos(n int) byte {
	return t.source.at(n)
}

// skip_whitespace, skips all whitespace characters
fn (mut t Tokenizer) skip_whitespace() {
	for t.ch != `\0` && t.ch.is_space() {
		if t.ch == `\r` {
			// Count \r\n as one line
			if t.peek_pos(1) == `\n` {
				t.incr_pos()
				t.source.add_line(t.start_line_pos, t.pos-1, 2)
				t.start_line_pos = t.pos
			}
		} else if t.peek_pos(0) == `\n` {
			t.source.add_line(t.start_line_pos, t.pos-1, 1)
			t.start_line_pos = t.pos
		}
		t.incr_pos()
	}
}

// is_name_char returns true if character is in a name
[inline]
pub fn is_name_char(c byte) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

// name, gets the name token
fn (mut t Tokenizer) read_identifier_or_keyword() {
	t.incr_pos()
	for t.ch != `\0` && (is_name_char(t.ch) || t.ch.is_digit()) {
		t.incr_pos()
	}
	name := t.source.str_range(t.start, t.pos)
	kind := keywords[name]
	if kind == .unknown {
		t.kind = .name
	} else {
		t.kind = kind
	}
}

// pos, returns current position
[inline]
fn (mut t Tokenizer) token_pos() util.Pos {
	return util.new_pos(t.pos, t.len)
}

// read_string_literal returns a string literal
fn (mut t Tokenizer) read_string_literal() {
	t.kind = .string
	q_char := t.ch
	t.incr_pos()
	for {
		if t.ch == `\0` {
			t.log.error('unfinished string literal', t.token_pos())
			return
		}
		if t.ch == q_char {
			t.incr_pos()
			return
		}
		t.incr_pos()
	}
}

// name, gets the number token
[inline]
fn (mut t Tokenizer) read_number_literal() {
	for t.ch != `\0` && t.ch.is_digit() {
		t.incr_pos()
	}
	t.kind = .number
}

// is_newline returns true if character is new line
[inline]
pub fn is_newline(c byte) bool {
	return c == `\r` || c == `\n`
}
