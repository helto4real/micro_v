module util

pub struct Diagnostic {
pub:
	pos  Pos    // position of error
	text string // error text
}

pub struct Diagnostics {
mut:
	iter_pos int
pub mut:
	all []Diagnostic
}

// iterator for more easy handling
pub fn (mut d Diagnostics) next() ?Diagnostic {
	if d.iter_pos < d.all.len {
		return d.all[d.iter_pos]
	}
	d.iter_pos = 0
	return none
}

pub fn (mut d Diagnostics) error(text string, pos Pos) {
	d.all << Diagnostic {
		text: text 
		pos: pos
	}
}


pub fn (mut d Diagnostics) error_expected(typ string, got string, expected string, pos Pos) {
	d.error('unexpected $typ: <$got>,  expected <$expected>', pos)
}
pub fn (mut d Diagnostics) error_unexpected(typ string, got string, pos Pos) {
	d.error('unexpected $typ: <$got>', pos)
}

pub fn (mut d Diagnostics) error_undefined_name(name string, pos Pos) {
	d.error('undefined name: <$name>', pos)
}