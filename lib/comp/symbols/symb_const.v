module symbols

import rand
import lib.comp.symbols

pub struct ConstSymbol {
pub:
	id     string
	typ    TypeSymbol
	val    LitVal	
}

pub fn (cs ConstSymbol) str() string {
	return '$cs.val'
}

pub fn (cs ConstSymbol) str_ident(level int) string {
	return '$cs.val'
}

pub fn new_const_symbol(val LitVal) ConstSymbol {
	return symbols.ConstSymbol{
		typ: val.typ()
		val: val
		id: rand.uuid_v4()
	}
}
