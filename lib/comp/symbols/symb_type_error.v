module symbols

import rand

pub struct ErrorTypeSymbol {
pub:
	kind TypeSymbolKind
	name string = 'error'
	id   string
}

pub fn (ts ErrorTypeSymbol) == (rts ErrorTypeSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts ErrorTypeSymbol) str() string {
	return ts.name
}

pub fn new_error_type_symbol() ErrorTypeSymbol {
	return ErrorTypeSymbol{
		kind: .error_symbol
		id: rand.uuid_v4()
	}
}
