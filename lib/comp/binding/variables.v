module binding

import lib.comp.types

pub struct Variable {
pub:
	name   string
	typ    types.Type
	val    types.LitVal
	is_mut bool
}

pub struct SymbolTable {
pub mut:
	vars map[string]Variable
}

pub fn new_symbol_table() &SymbolTable {
	return &SymbolTable{}
}
