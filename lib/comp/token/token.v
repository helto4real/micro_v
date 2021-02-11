module token

pub struct Token {
pub:
	kind Kind   // the token number/enum; for quick comparisons
	lit  string // literal representation of the token
	pos  Pos	// position in the file
	
}

pub fn (t Token) str() string {
	return 'tok: [${t.pos.pos}, (${t.pos.ln}, ${t.pos.col})] $t.kind \'${t.lit}\''
}

pub struct Pos {
pub:
	pos int // position in textfile
	ln  int	// line number
	col int // column of line
}

// Kind of token
pub enum Kind {
	unknown
	error
	name
	number
	string
	lcbr
	rcbr
	lpar
	rpar
	colon
	dot
	assign
	decl_assign
	div
	amp
	eof
	keyword_beg
	key_fn
	key_module
	key_struct
	keyword_end
	_end_
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
	s[Kind.assign] = '='
	s[Kind.div] = '/'
	s[Kind.amp] = '&'
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.dot] = '.'
	s[Kind.colon] = ':'
	s[Kind.key_fn] = 'fn'
	s[Kind.key_module] = 'module'
	s[Kind.key_struct] = 'struct'
	return s
}