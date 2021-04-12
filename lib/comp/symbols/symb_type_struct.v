module symbols

import rand

pub struct StructTypeSymbol {
pub:
	kind   TypeSymbolKind
	mod    string 
	name   string
	id     string
	is_ref bool
pub mut:
	members []StructTypeMember
}

pub fn (ss StructTypeSymbol) == (rss StructTypeSymbol) bool {
	return ss.name == rss.name
}

pub fn (ss StructTypeSymbol) str() string {
	return ss.name
}

pub fn (ss StructTypeSymbol) to_ref_type() StructTypeSymbol {
	return StructTypeSymbol{
		...ss
		is_ref: true
	}
}

pub fn new_struct_symbol(mod string, name string, is_ref bool) StructTypeSymbol {
	return StructTypeSymbol{
		kind: .struct_symbol
		mod: mod
		name: name
		id: rand.uuid_v4()
	}
}

pub struct StructTypeMember {
pub:
	ident string
	typ   TypeSymbol
	is_ref bool
}

pub fn new_struct_type_member(ident string, typ TypeSymbol) StructTypeMember {
	return StructTypeMember{
		ident: ident
		typ: typ
	}
}
