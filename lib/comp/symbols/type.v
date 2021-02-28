module symbols
pub const (
	int_symbol = new_type_symbol('int')
	bool_symbol = new_type_symbol('bool')
	string_symbol = new_type_symbol('string')
	error_symbol = new_type_symbol('?')
	undefined_symbol = new_type_symbol('undefined')
)
pub struct TypeSymbol {
pub:
	name   string
}

pub fn (ts TypeSymbol) == (rts TypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts TypeSymbol) str() string {
	return ts.name
}

pub fn new_type_symbol(name string) TypeSymbol {
	return TypeSymbol {
		name: name
	}
}
