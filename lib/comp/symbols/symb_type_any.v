module symbols

import rand

pub struct AnyTypeSymbol {
pub:
	kind   TypeSymbolKind
	mod    string = 'lib.runtime'
	name   string = 'any'
	id     string
	is_ref bool
}

pub fn (ts AnyTypeSymbol) == (rts AnyTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts AnyTypeSymbol) str() string {
	return ts.name
}

pub fn (ss AnyTypeSymbol) to_ref_type() AnyTypeSymbol {
	return AnyTypeSymbol{
		...ss
		is_ref: true
	}
}

pub fn new_any_type_symbol(is_ref bool) AnyTypeSymbol {
	return AnyTypeSymbol{
		kind: .any_symbol
		id: rand.uuid_v4()
		is_ref: is_ref
	}
}
