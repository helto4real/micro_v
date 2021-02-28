module symbols

import lib.comp.types

[heap]
pub struct TypeSymbol {
pub:
	name   string
	typ    types.Type
}

pub fn (ts &TypeSymbol) str() string {
	return ts.name
}

pub fn new_type_symbol(name string, typ types.Type) &TypeSymbol {
	return &TypeSymbol{
		name: name
		typ: typ
	}
}