module symbols

import rand

pub struct ArrayTypeSymbol {
pub:
	kind   TypeSymbolKind
	mod    string = 'lib.runtime'
	name   string
	id     string
	is_ref bool

	elem_typ     TypeSymbol
	len          int
	is_fixed     bool
	is_val_array bool
}

// pub fn (ss ArrayTypeSymbol) == (rss ArrayTypeSymbol) bool {
// 	return ss.elem_typ.name == rss.elem_typ.name
// }

pub fn (ss ArrayTypeSymbol) str() string {
	return ss.name
}

pub fn (ss &ArrayTypeSymbol) to_ref_type() ArrayTypeSymbol {
	unbox := *ss
	return ArrayTypeSymbol{
		...unbox
		is_ref: true
	}
}

pub fn new_fixed_val_array_symbol(elem_typ TypeSymbol, len int, is_ref bool) ArrayTypeSymbol {
	return ArrayTypeSymbol{
		kind: .array_symbol
		name: '[$len]$elem_typ.name'
		id: rand.uuid_v4()
		elem_typ: elem_typ
		is_ref: is_ref
		len: len
		is_fixed: true
		is_val_array: true
	}
}
