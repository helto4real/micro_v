module source

pub struct Diagnostic {
pub:
	pos  Pos    // position of error
	text string // error text
}

pub struct Diagnostics {
mut:
	iter_pos int
pub mut:
	all []&Diagnostic
}

pub fn new_diagonistics() &Diagnostics {
	return &Diagnostics{}
}

pub fn (mut d Diagnostics) merge(from_diag &Diagnostics) {
	for diag in from_diag {
		d.all << diag
	}
}

// iterator for more easy handling
pub fn (mut d Diagnostics) next() ?&Diagnostic {
	if d.iter_pos < d.all.len {
		ret := d.all[d.iter_pos]
		d.iter_pos++
		return ret
	}
	d.iter_pos = 0
	return none
}

pub fn (mut d Diagnostics) error(text string, pos Pos) {
	d.all << &Diagnostic{
		text: text
		pos: pos
	}
}

pub fn (mut d Diagnostics) error_ex(text string) {
	d.all << &Diagnostic{
		text: text
		pos: Pos{}
	}
}
