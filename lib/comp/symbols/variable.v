module symbols

import lib.comp.symbols

[heap]
pub struct VariableSymbol {
pub:
	name   string
	typ    symbols.TypeSymbol
	is_mut bool
}

pub fn (vs &VariableSymbol) str() string {
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return 'var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn (vs &VariableSymbol) str_ident(level int) string {
	ident := '  '.repeat(level)
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return '${ident}var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn new_variable_symbol(name string, typ symbols.TypeSymbol, is_mut bool) &VariableSymbol {
	return &VariableSymbol{
		name: name
		typ: typ
		is_mut: is_mut
	}
}