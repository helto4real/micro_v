module symbols

import rand

pub struct BuiltInTypeSymbol {
pub:
	name string = 'undefined'
	id   string
}

pub fn (ts BuiltInTypeSymbol) == (rts BuiltInTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts BuiltInTypeSymbol) str() string {
	return ts.name
}

pub fn new_builtin_type_symbol(name string) BuiltInTypeSymbol {
	return BuiltInTypeSymbol{
		name: name
		id: rand.uuid_v4()
	}
}
