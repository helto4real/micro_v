module symbols

import rand

pub struct StructTypeSymbol {
pub:
	ident string 
	id   string

	members []StructTypeMember
}

pub fn (ss StructTypeSymbol) == (rss StructTypeSymbol) bool {
	return ss.ident == rss.ident
}

pub fn (ss StructTypeSymbol) str() string {
	return ss.ident
}

pub fn new_struct_symbol(ident string) StructTypeSymbol {
	return StructTypeSymbol{
		ident: ident
		id: rand.uuid_v4()
	}
}

pub struct StructTypeMember {
pub:
	ident string
	typ TypeSymbol
}

pub fn new_struct_type_member(ident string, typ TypeSymbol) StructTypeMember {
	return StructTypeMember {
		ident: ident
		typ: typ
	}
}
