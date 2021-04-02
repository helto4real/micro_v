module symbols

pub const (
	// symbols
	int_symbol         = new_builtin_type_symbol('int')
	i64_symbol         = new_builtin_type_symbol('i64')
	bool_symbol        = new_builtin_type_symbol('bool')
	string_symbol      = new_builtin_type_symbol('string')
	undefined_symbol   = new_builtin_type_symbol('undefined')
	none_symbol   	   = new_builtin_type_symbol('none')
	// C interop
	charptr_symbol      = new_builtin_type_symbol('charptr')
	voidptr_symbol      = new_builtin_type_symbol('voidptr')

	any_symbol         = new_any_type_symbol()
	error_symbol       = new_error_type_symbol()
	void_symbol        = new_void_type_symbol()

	// built-in function symbols
	println_symbol     = new_function_symbol('println', [new_param_symbol('text', string_symbol,
		false)], void_symbol)
	print_symbol       = new_function_symbol('print', [new_param_symbol('text', string_symbol,
		false)], void_symbol)
	exit_symbol       = new_function_symbol('exit', [new_param_symbol('exit_code', int_symbol,
		false)], void_symbol)
	input_symbol       = new_function_symbol('input', [], string_symbol)
	built_in_functions = [println_symbol, print_symbol, input_symbol, exit_symbol]
)
