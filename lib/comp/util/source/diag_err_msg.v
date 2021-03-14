module source

pub fn (mut d Diagnostics) error_expected(typ string, got string, expected string, loc TextLocation) {
	d.error('unexpected $typ: <$got>,  expected <$expected>', loc)
}

pub fn (mut d Diagnostics) error_unexpected(typ string, got string, loc TextLocation) {
	d.error('unexpected $typ: <$got>', loc)
}

pub fn (mut d Diagnostics) error_var_not_exists(name string, loc TextLocation) {
	d.error('variable <$name> does not exist', loc)
}

pub fn (mut d Diagnostics) error_name_already_defined(name string, loc TextLocation) {
	d.error('name: <$name> already defined', loc)
}

pub fn (mut d Diagnostics) error_assign_non_mutable_variable(name string, loc TextLocation) {
	d.error('assign non mutable varable: <$name>', loc)
}

pub fn (mut d Diagnostics) error_cannot_convert_variable_type(from_type string, to_type string, loc TextLocation) {
	d.error('cannot convert type <$from_type> to <$to_type>', loc)
}

pub fn (mut d Diagnostics) error_expected_var_decl(loc TextLocation) {
	d.error('expected varable declaration after mut keyword', loc)
}

pub fn (mut d Diagnostics) error_expected_bool_expr(loc TextLocation) {
	d.error('expected boolean expression', loc)
}

pub fn (mut d Diagnostics) error_expected_correct_type_expr(expeced_type string, actual_type string, loc TextLocation) {
	d.error('expected type <$expeced_type> in expression, got <$actual_type>', loc)
}

pub fn (mut d Diagnostics) error_expected_same_type_in_range_expr(typ string, loc TextLocation) {
	d.error('expected same type <$typ> in range_expr expression', loc)
}

pub fn (mut d Diagnostics) error_undefined_function(name string, loc TextLocation) {
	d.error('undefined function <$name>.', loc)
}

pub fn (mut d Diagnostics) error_wrong_argument_count(name string, arg_count int, loc TextLocation) {
	d.error('wrong number of arguments in function <$name>. Expected $arg_count', loc)
}

pub fn (mut d Diagnostics) error_cannot_convert_type(from_typ string, to_typ string, loc TextLocation) {
	d.error('cannot convert from type <$from_typ> to <$to_typ>', loc)
}

pub fn (mut d Diagnostics) error_wrong_argument_type(name string, param_typ string, arg_typ string, loc TextLocation) {
	d.error('wrong argument type <$arg_typ> for argument <$name>. Expected type <$param_typ>',
		loc)
}

pub fn (mut d Diagnostics) error_empty_block_not_allowed(loc TextLocation) {
	d.error('empty block is not allowed', loc)
}

pub fn (mut d Diagnostics) error_expected_block_end_with_expression(loc TextLocation) {
	d.error('expected block to end with expression', loc)
}

pub fn (mut d Diagnostics) error_return_type_differ_expect_type(then_typ string, else_typ string, loc TextLocation) {
	d.error('values returned in expression is different in `if`and `else` block. expected type: <$then_typ> got:<$else_typ>',
		loc)
}

pub fn (mut d Diagnostics) error_undefined_type(ident string, loc TextLocation) {
	d.error('type name <$ident> does not exist', loc)
}

pub fn (mut d Diagnostics) error_param_allready_declared(ident string, loc TextLocation) {
	d.error('parameter <$ident> already declared', loc)
}

pub fn (mut d Diagnostics) error_function_allready_declared(ident string, loc TextLocation) {
	d.error('function <$ident> already declared', loc)
}

pub fn (mut d Diagnostics) error_keyword_are_only_allowed_inside_a_loop(keyword string, loc TextLocation) {
	d.error('statment <$keyword> are only allowed inside a loop', loc)
}

pub fn (mut d Diagnostics) error_invalid_return_expr(fn_name string, loc TextLocation) {
	d.error('function <$fn_name> does not return a value, return cannot return an expression',
		loc)
}

pub fn (mut d Diagnostics) error_expected_return_value(typ_name string, loc TextLocation) {
	d.error('return value of type <$typ_name> expected', loc)
}

pub fn (mut d Diagnostics) error_invalid_return(loc TextLocation) {
	d.error("the 'return' keyword cannot be used outside a function", loc)
}

pub fn (mut d Diagnostics) error_all_paths_must_return(loc TextLocation) {
	d.error("all code paths must 'return' in function", loc)
}

pub fn (mut d Diagnostics) error_module_can_only_be_defined_once(loc TextLocation) {
	d.error('a module can only be definded once', loc)
}

pub fn (mut d Diagnostics) error_module_can_only_be_defined_as_first_statement(loc TextLocation) {
	d.error('a module can only be definded as first statement', loc)
}
