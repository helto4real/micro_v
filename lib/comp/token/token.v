module token

import lib.comp.util

pub const (
	tok_void  = Token{
		kind: .void
		lit: 'void'
	}
	nr_tokens = int(Kind._end_)
	token_str = build_token_str()
	keywords  = build_keys()
)

pub struct Token {
pub:
	kind Kind     // the token number/enum; for quick comparisons
	lit  string   // literal representation of the token
	pos  util.Pos // position in the file
}

pub fn (t Token) str() string {
	return "tok: [$t.pos.pos, ($t.pos.len) $t.kind '$t.lit'"
	// return "tok: [$t.pos.pos, ($t.pos.ln, $t.pos.col)] $t.kind '$t.lit'"
}

pub fn (ex Token) node_str() string {
	return ex.lit
}

// Kind of token
pub enum Kind {
	unknown
	bad_token // bad token
	name // Any identifier name
	number //[1-9]+
	string // a string literal
	lcbr // '{'
	rcbr // '}'
	lpar // '('
	rpar // ')'
	tilde // '~'
	colon // ':'
	semcol // ';'
	dot // '.'
	dot_dot // '..'
	comma // ','
	eq // '='
	gt // '>'
	lt // '<'
	colon_eq // ':='
	plus // '+'
	minus // '-'
	mul // '*'
	div // '/'
	amp // '&'
	pipe // '|'
	eq_eq // '=='
	gt_eq // '>='
	lt_eq // '<='
	exl_mark_eq // '!='
	exl_mark // '!'
	hat // '^'
	pipe_pipe // '||'
	amp_amp // '&&'
	eof // end of file
	void // used to non existin token
	// Keywords
	keyword_beg // start of keywords
	key_fn // 'fn'
	key_if // 'if'
	key_else // 'else'
	key_continue // 'continue'
	key_break // 'break'
	key_return // 'return'
	key_module // 'module'
	key_struct // 'struct'
	key_true // 'true'
	key_false // 'false'
	key_mut // 'mut'
	key_for // 'for'
	key_in // 'in'
	keyword_end // end of keywords
	_end_ // end of enum
}

pub fn build_keys() map[string]Kind {
	mut res := map[string]Kind{}
	for t in int(Kind.keyword_beg) + 1 .. int(Kind.keyword_end) {
		key := token.token_str[t]
		res[key] = Kind(t)
	}
	return res
}

fn build_token_str() []string {
	mut s := []string{len: token.nr_tokens}
	s[Kind.unknown] = 'token_unknown'
	s[Kind.bad_token] = 'bad_token'
	s[Kind.eof] = 'eof'
	s[Kind.name] = '' // no default value
	s[Kind.string] = '' // no default value
	s[Kind.number] = '' // no default value
	s[Kind.eq] = '='
	s[Kind.gt] = '>'
	s[Kind.lt] = '<'
	s[Kind.colon_eq] = ':='
	s[Kind.eq_eq] = '=='
	s[Kind.lt_eq] = '<='
	s[Kind.gt_eq] = '>='
	s[Kind.exl_mark_eq] = '!='
	s[Kind.plus] = '+'
	s[Kind.minus] = '-'
	s[Kind.mul] = '*'
	s[Kind.div] = '/'
	s[Kind.amp] = '&'
	s[Kind.pipe] = '|'
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.tilde] = '~'
	s[Kind.hat] = '^'
	s[Kind.dot_dot] = '..'
	s[Kind.comma] = ','
	s[Kind.colon] = ':'
	s[Kind.semcol] = ';'
	s[Kind.pipe_pipe] = '||'
	s[Kind.amp_amp] = '&&'
	s[Kind.exl_mark] = '!'
	s[Kind.key_mut] = 'mut'
	s[Kind.key_true] = 'true'
	s[Kind.key_false] = 'false'
	s[Kind.key_fn] = 'fn'
	s[Kind.key_if] = 'if'
	s[Kind.key_else] = 'else'
	s[Kind.key_continue] = 'continue'
	s[Kind.key_break] = 'break'
	s[Kind.key_return] = 'return'
	s[Kind.key_module] = 'module'
	s[Kind.key_struct] = 'struct'
	s[Kind.key_for] = 'for'
	s[Kind.key_in] = 'in'
	return s
}
