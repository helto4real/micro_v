module symbols

pub const (
	// symbols
	int_symbol         = new_type_symbol('int')
	bool_symbol        = new_type_symbol('bool')
	string_symbol      = new_type_symbol('string')
	void_symbol        = new_type_symbol('void')
	error_symbol       = new_type_symbol('?')
	undefined_symbol   = new_type_symbol('undefined')
	none_symbol        = new_type_symbol('none')

	// built-in function symbols
	println_symbol     = new_function_symbol('println', [new_param_symbol('text', string_symbol,
		false)], void_symbol)
	print_symbol       = new_function_symbol('print', [new_param_symbol('text', string_symbol,
		false)], void_symbol)
	input_symbol       = new_function_symbol('input', [], string_symbol)
	built_in_functions = [println_symbol, print_symbol, input_symbol]
)
