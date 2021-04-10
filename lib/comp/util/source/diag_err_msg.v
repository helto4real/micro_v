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

pub fn (mut d Diagnostics) error_member_not_exists(name string, loc TextLocation) {
	d.error('member <$name> does not exist', loc)
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

pub fn (mut d Diagnostics) error_cannot_convert_implicitly(from_type string, to_type string, loc TextLocation) {
	d.error('cannot convert explicitly from <$from_type> to type <$to_type>', loc)
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

pub fn (mut d Diagnostics) error_convertion_differ_by_reference(is_ref bool, conv string, loc TextLocation) {
	ref_name := if is_ref { '&$conv' } else { conv }
	d.error('convertion differ by reference, did you mean $ref_name?', loc)
}

pub fn (mut d Diagnostics) error_only_variables_can_be_input_to_mutable_parameters(loc TextLocation) {
	d.error('only variables can be input to mutable parameters', loc)
}

pub fn (mut d Diagnostics) error_provide_mut_keyword_for_mutable_parameters(loc TextLocation) {
	d.error('the argument is mutable, provide the `mut` keyword before argument', loc)
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

pub fn (mut d Diagnostics) error_variadic_parameters_can_only_be_last(ident string, loc TextLocation) {
	d.error('variadic parameter <$ident> can only be last parameter', loc)
}

pub fn (mut d Diagnostics) error_function_allready_declared(ident string, loc TextLocation) {
	d.error('function <$ident> already declared', loc)
}

pub fn (mut d Diagnostics) error_missing_main_func() {
	d.error_msg('no main function declared')
}

pub fn (mut d Diagnostics) error_struct_allready_declared(name string, loc TextLocation) {
	d.error('struct <$name> already declared', loc)
}

pub fn (mut d Diagnostics) error_elements_in_array_needs_to_be_of_same_type(first_elem_typ string, first_elem_is_ref bool, loc TextLocation) {
	if !first_elem_is_ref {
		d.error('element needs to be of the same type ($first_elem_typ) and not a reference type',
			loc)
	} else {
		d.error('element needs to be of the same type ($first_elem_typ) and a reference type',
			loc)
	}
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

pub fn (mut d Diagnostics) error_expression_does_not_support_indexing(loc TextLocation) {
	d.error('the expression does not support indexing', loc)
}

pub fn (mut d Diagnostics) error_variable_type_is_not_an_array(loc TextLocation) {
	d.error('variable type is not an array', loc)
}

pub fn (mut d Diagnostics) error_all_paths_must_return(loc TextLocation) {
	d.error("all code paths must 'return' in function", loc)
}

pub fn (mut d Diagnostics) error_module_can_only_be_defined_once(loc TextLocation) {
	d.error('a module can only be definded once', loc)
}

pub fn (mut d Diagnostics) error_a_fixed_value_array_cannot_be_muted(loc TextLocation) {
	d.error('fixed value array cannot be mut', loc)
}

pub fn (mut d Diagnostics) error_module_can_only_be_defined_as_first_statement(loc TextLocation) {
	d.error('a module can only be definded as first statement', loc)
}

pub fn (mut d Diagnostics) error_invalid_expression_statement(loc TextLocation) {
	d.error('only assignment and call expressions can be used as a statement', loc)
}

pub fn (mut d Diagnostics) error_cannot_mix_global_statements_and_main_function(loc TextLocation) {
	d.error('cannot mix global statements with definition of a main function', loc)
}

pub fn (mut d Diagnostics) error_main_function_must_have_correct_signature(loc TextLocation) {
	d.error('main function must have correct signature, `fn main() {}', loc)
}

pub fn (mut d Diagnostics) error_global_stmts_can_only_be_defined_in_one_file(loc TextLocation) {
	d.error('global statements can only be defined in one file/syntax tree', loc)
}

pub fn (mut d Diagnostics) error_structs_fields_declared_on_init(loc TextLocation) {
	d.error('struct fields can only be declared during the initialization', loc)
}
