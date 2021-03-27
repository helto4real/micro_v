module symbols

import rand

pub struct VoidTypeSymbol {
pub:
	kind TypeSymbolKind
	name string = 'void'
	id   string
}

pub fn (ts VoidTypeSymbol) == (rts VoidTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts VoidTypeSymbol) str() string {
	return ts.name
}

pub fn new_void_type_symbol() VoidTypeSymbol {
	return VoidTypeSymbol{
		kind: .void_symbol
		id: rand.uuid_v4()
	}
}
