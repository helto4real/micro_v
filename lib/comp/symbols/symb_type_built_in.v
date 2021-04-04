module symbols

import rand

pub struct BuiltInTypeSymbol {
pub:
	kind   TypeSymbolKind
	name   string = 'undefined'
	id     string
	is_ref bool
}

pub fn (ts BuiltInTypeSymbol) == (rts BuiltInTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts BuiltInTypeSymbol) str() string {
	return ts.name
}

pub fn (ss BuiltInTypeSymbol) to_ref_type() BuiltInTypeSymbol {
	return BuiltInTypeSymbol{
		...ss
		is_ref: true
	}
}

pub fn new_builtin_type_symbol(name string) BuiltInTypeSymbol {
	return BuiltInTypeSymbol{
		kind: .built_in_symbol
		name: name
		id: rand.uuid_v4()
	}
}
