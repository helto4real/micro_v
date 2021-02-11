module token

pub struct Tokenizer {
	code string // code tokenized
mut:
	pos int // current position in file
	ln  int // current line being parsed
	col int // current colum being parsed
}

// instance a tokenizer from string
pub fn new_tokenizer_from_string(code string) &Tokenizer {
	return &Tokenizer{
		code: code
	}
}

pub fn (t &Tokenizer) next_token() Token {

	if pos >= code.len {
		return token(.eof, 'eof') 
	}

	
	return token(.error, 'error')
}

[inline]
fn (t &Tokenizer) token(kind Kind, lit string) Token {
	return Token {
		kind: kind
		lit: lit
		pos: Pos{
			pos: t.pos
			ln: t.ln
			col: t.col
		}
	}
}