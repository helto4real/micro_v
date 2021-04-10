module symbols

pub const (
	// symbols
	int_symbol         = new_builtin_type_symbol(.int_symbol, 'int')
	byte_symbol        = new_builtin_type_symbol(.byte_symbol, 'byte')
	char_symbol        = new_builtin_type_symbol(.char_symbol, 'char')
	i64_symbol         = new_builtin_type_symbol(.i64_symbol, 'i64')
	bool_symbol        = new_builtin_type_symbol(.bool_symbol, 'bool')
	string_symbol      = new_builtin_type_symbol(.string_symbol, 'string')
	undefined_symbol   = new_builtin_type_symbol(.undefined_symbol, 'undefined')
	none_symbol        = new_builtin_type_symbol(.none_symbol, 'none')
	// C interoptyp,
	voidptr_symbol     = new_builtin_type_symbol(.voidptr_symbol, 'voidptr')

	any_symbol         = new_any_type_symbol(false)
	error_symbol       = new_error_type_symbol()
	void_symbol        = new_void_type_symbol()
	empty_var_symbol   = new_empty_local_variable_symbol()

	builtin_types      = builtin_types()

	// built-in function symbols
	println_symbol     = new_function_symbol('println', [
		new_param_symbol('text', string_symbol, false, false, false),
	], void_symbol)
	print_symbol       = new_function_symbol('print', [
		new_param_symbol('text', string_symbol, false, false, false),
	], void_symbol)
	exit_symbol        = new_function_symbol('exit', [
		new_param_symbol('exit_code', int_symbol, false, false, false),
	], void_symbol)
	input_symbol       = new_function_symbol('input', [], string_symbol)
	built_in_functions = [println_symbol, print_symbol, input_symbol, exit_symbol]
)

pub fn builtin_types() []TypeSymbol {
	return [
		TypeSymbol(symbols.int_symbol),
		symbols.byte_symbol,
		symbols.char_symbol,
		symbols.i64_symbol,
		symbols.bool_symbol,
		symbols.string_symbol,
		symbols.undefined_symbol,
		symbols.none_symbol,
		symbols.voidptr_symbol,
	]
}
