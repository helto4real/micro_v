module symbols

import rand

pub struct TypeSymbol {
pub:
	name string = 'undefined'
	id   string
}

pub fn (ts TypeSymbol) == (rts TypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts TypeSymbol) str() string {
	return ts.name
}

pub fn new_type_symbol(name string) TypeSymbol {
	return TypeSymbol{
		name: name
		id: rand.uuid_v4()
	}
}
