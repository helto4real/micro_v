module token

pub struct Tokenizer {
	code string // code tokenized
mut:
	pos    int 		   // current position in file
	ln     int = 1 	   // current line being parsed
	col    int = 1 	   // current colum being parsed
	ch     byte = `\0` // current char
	is_eof bool
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(code string) &Tokenizer {
	if code.len > 0 {

	}
	return &Tokenizer{
		code: code
		ch: if code.len > 0 {code[0]} else {`\0`}
		is_eof: if code.len > 0 {false} else {true}
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
	
	if is_name_char(t.ch) {
			name := t.ident_name()
			kind := keywords[name]
			if kind == .unknown {
				return t.token(.name, name, name.len)
			} else {
				return t.token(kind, name, name.len)
			}
		} 
	return t.token(.error, '${t.ch.ascii_str()}', 1)
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

[inline]
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

[inline]
// skip, skips n chars
fn (mut t Tokenizer) skip(n int) {
	if t.pos + n < t.code.len {
		t.pos+=n
		t.col+=n
	} else {
		t.col+=n
		t.pos = t.code.len 
		t.is_eof = true
		t.ch = `\0`
		// todo: error here
	}
}

[inline]
// peek, peeks the character at pos + n or '\0' if eof
fn (mut t Tokenizer) peek(n int) byte {
	if t.pos + n < t.code.len {
		return t.code[t.pos + n]
	} else {
		return `\0`
	}
}


[inline]
// skip_whitespace, skips all whitespace characters
fn (mut t Tokenizer) skip_whitespace() {
	for !t.is_eof && t.ch.is_space() {
		if t.ch == `\r` {
			//Count \r\n as one line
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

[inline]
// inc_line_nr, increments line number
fn (mut t Tokenizer) inc_line_nr() {
	t.ln++
	t.col = 1
}

[inline]
// is_name_char returns true if character is in a name
pub fn is_name_char(c byte) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

[inline]
// ident_name, gets the name of identifier
fn (mut t Tokenizer) ident_name() string {
	start := t.pos
	t.next()
	for !t.is_eof && (is_name_char(t.ch) || t.ch.is_digit()) {
		t.next()
	}
	name := t.code[start..t.pos]
	// s.pos--
	return name
}

[inline]
// is_nl returns true if character is new line
pub fn is_nl(c byte) bool {
	return c == `\r` || c == `\n`
}


