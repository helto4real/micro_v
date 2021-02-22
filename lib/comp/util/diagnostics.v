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

pub fn (mut d Diagnostics) error_expected(typ string, got string, expected string, pos Pos) {
	d.error('unexpected $typ: <$got>,  expected <$expected>', pos)
}

pub fn (mut d Diagnostics) error_unexpected(typ string, got string, pos Pos) {
	d.error('unexpected $typ: <$got>', pos)
}

pub fn (mut d Diagnostics) error_var_not_exists(name string, pos Pos) {
	d.error('variable <$name> does not exist', pos)
}

pub fn (mut d Diagnostics) error_name_already_defined(name string, pos Pos) {
	d.error('name: <$name> already defined', pos)
}

pub fn (mut d Diagnostics) error_assign_non_mutable_variable(name string, pos Pos) {
	d.error('assign non mutable varable: <$name>', pos)
}

pub fn (mut d Diagnostics) error_cannot_convert_variable_type(from_type string, to_type string, pos Pos) {
	d.error('cannot convert type <$from_type> to <$to_type>', pos)
}

pub fn (mut d Diagnostics) error_expected_var_decl(pos Pos) {
	d.error('expected varable declaration after mut keyword', pos)
}

pub fn (mut d Diagnostics) error_expected_bool_expr(pos Pos) {
	d.error('expected boolean expression', pos)
}

