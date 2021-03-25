module symbols

import rand

pub struct AnyTypeSymbol {
pub:
	kind TypeSymbolKind
	name string = 'any'
	id   string
}

pub fn (ts AnyTypeSymbol) == (rts AnyTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts AnyTypeSymbol) str() string {
	return ts.name
}

pub fn new_any_type_symbol() AnyTypeSymbol {
	return AnyTypeSymbol{
		kind: .any_symbol
		id: rand.uuid_v4()
	}
}
