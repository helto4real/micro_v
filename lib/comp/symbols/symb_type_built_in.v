module symbols

import rand

pub struct BuiltInTypeSymbol {
pub:
	kind   TypeSymbolKind = .undefined_symbol
	mod    string = 'lib.runtime'
	name   string
	id     string
	is_ref bool
}

pub fn (ts BuiltInTypeSymbol) == (rts BuiltInTypeSymbol) bool {
	return ts.kind == rts.kind
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

pub fn new_builtin_type_symbol(kind TypeSymbolKind, name string) BuiltInTypeSymbol {
	return BuiltInTypeSymbol{
		kind: kind
		name: name
		id: rand.uuid_v4()
	}
}
