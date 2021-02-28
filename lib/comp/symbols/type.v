module symbols

pub struct TypeSymbol {
pub:
	name   string
}

pub fn (ts TypeSymbol) str() string {
	return ts.name
}

pub fn new_int_symbol() TypeSymbol {
	return TypeSymbol{
		name: 'int'
	}
}

pub fn new_bool_symbol() TypeSymbol {
	return TypeSymbol{
		name: 'bool'
	}
}

pub fn new_string_symbol() TypeSymbol {
	return TypeSymbol{
		name: 'string'
	}
}