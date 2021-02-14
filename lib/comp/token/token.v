module token

import lib.comp.util

pub struct Token {
pub:
	kind Kind     // the token number/enum; for quick comparisons
	lit  string   // literal representation of the token
	pos  util.Pos // position in the file
}

pub fn (t Token) str() string {
	return "tok: [$t.pos.pos, ($t.pos.ln, $t.pos.col)] $t.kind '$t.lit'"
}

// Kind of token
pub enum Kind {
	unknown
	error // error
	name // Any identifier name
	number //[1-9]+
	string // a string literal
	lcbr // '{'
	rcbr // '}'
	lpar // '('
	rpar // ')'
	colon // ':'
	semcol // ';'
	dot // '.'
	comma // ','
	assign // '='
	decl_assign // ':='
	plus // '+'
	minus // '-'
	mul // '*'
	div // '/'
	amp // '&'
	pipe // '|'
	eq // '=='
	ne // '!='
	not // '!'
	pipe_pipe // '||'
	amp_amp // '&&'
	eof // end of file
	// Keywords
	keyword_beg // start of keywords
	key_fn // 'fn'
	key_module // 'module'
	key_struct // 'struct'
	key_true // 'true'
	key_false // 'false'
	keyword_end // end of keywords
	_end_ // end of enum
}

pub const (
	nr_tokens = int(Kind._end_)
	token_str = build_token_str()
	keywords  = build_keys()
)

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
	s[Kind.error] = 'token_error'
	s[Kind.eof] = 'eof'
	s[Kind.name] = 'name'
	s[Kind.string] = 'string'
	s[Kind.number] = 'number'
	s[Kind.assign] = '='
	s[Kind.decl_assign] = ':='
	s[Kind.eq] = '=='
	s[Kind.ne] = '!='
	s[Kind.plus] = '+'
	s[Kind.div] = '-'
	s[Kind.mul] = '*'
	s[Kind.div] = '/'
	s[Kind.amp] = '&'
	s[Kind.pipe] = '|'
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.dot] = '.'
	s[Kind.comma] = ','
	s[Kind.colon] = ':'
	s[Kind.semcol] = ';'
	s[Kind.pipe_pipe] = '||'
	s[Kind.amp_amp] = '&&'
	s[Kind.not] = '!'
	s[Kind.key_true] = 'true'
	s[Kind.key_false] = 'false'
	s[Kind.key_fn] = 'fn'
	s[Kind.key_module] = 'module'
	s[Kind.key_struct] = 'struct'
	return s
}
