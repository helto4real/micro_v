module symbols

import rand

pub struct ErrorTypeSymbol {
pub:
	kind   TypeSymbolKind
	mod    string = 'lib.runtime'
	name   string = 'error'
	id     string
	is_ref bool
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
