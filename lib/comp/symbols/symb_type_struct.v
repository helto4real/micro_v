module symbols

import rand

pub struct StructTypeSymbol {
pub:
	kind TypeSymbolKind
	name string
	id   string
pub mut:
	members []StructTypeMember
}

pub fn (ss StructTypeSymbol) == (rss StructTypeSymbol) bool {
	return ss.name == rss.name
}

pub fn (ss StructTypeSymbol) str() string {
	return ss.name
}

pub fn new_struct_symbol(name string) StructTypeSymbol {
	return StructTypeSymbol{
		kind: .struct_symbol
		name: name
		id: rand.uuid_v4()
	}
}

pub struct StructTypeMember {
pub:
	ident string
	typ   TypeSymbol
}

pub fn new_struct_type_member(ident string, typ TypeSymbol) StructTypeMember {
	return StructTypeMember{
		ident: ident
		typ: typ
	}
}
