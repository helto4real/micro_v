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

pub fn (mut d Diagnostics) error_expected_correct_type_expr(expeced_type string, actual_type string, pos Pos) {
	d.error('expected type <$expeced_type> in expression, got <$actual_type>', pos)
}

pub fn (mut d Diagnostics) error_expected_same_type_in_range_expr(typ string, pos Pos) {
	d.error('expected same type <$typ> in range_expr expression', pos)
}

pub fn (mut d Diagnostics) error_undefined_function(name string, pos Pos) {
	d.error('undefined function <$name>.', pos)
}

pub fn (mut d Diagnostics) error_wrong_argument_count(name string, arg_count int, pos Pos) {
	d.error('wrong number of arguments in function <$name>. Expected $arg_count', pos)
}

pub fn (mut d Diagnostics) error_cannot_convert_type(from_typ string, to_typ string, pos Pos) {
	d.error('cannot convert from type <$from_typ> to <$to_typ>', pos)
}

pub fn (mut d Diagnostics) error_wrong_argument_type(name string, param_typ string, arg_typ string, pos Pos) {
	d.error('wrong argument type <$arg_typ> for argument <$name>. Expected type <$param_typ>',
		pos)
}
pub fn (mut d Diagnostics) error_empty_block_not_allowed(pos Pos) {
	d.error('empty block is not allowed',
		pos)
}
pub fn (mut d Diagnostics) error_expected_block_end_with_expression(pos Pos) {
	d.error('expected block to end with expression',
		pos)
}

pub fn (mut d Diagnostics) error_return_type_differ_expect_type(then_typ string, else_typ string, pos Pos) {
	d.error('values returned in expression is different in `if`and `else` block. expected type: <$then_typ> got:<$else_typ>', pos)
}

pub fn (mut d Diagnostics) error_undefined_type(ident string, pos Pos) {
	d.error('type name <$ident> does not exist', pos)
}

pub fn (mut d Diagnostics) error_param_allready_declared(ident string, pos Pos) {
	d.error('parameter <$ident> already declared', pos)
}

pub fn (mut d Diagnostics) error_function_allready_declared(ident string, pos Pos) {
	d.error('function <$ident> already declared', pos)
}

pub fn (mut d Diagnostics) error_functions_not_supported(ident string, pos Pos) {
	d.error('functions <$ident> not supported', pos)
}