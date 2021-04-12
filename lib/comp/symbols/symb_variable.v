module symbols

import rand
import lib.comp.symbols

pub struct LocalVariableSymbol {
pub:
	name     string
	typ      TypeSymbol
	mod      string
	is_mut   bool
	is_ref   bool
	id       string
	is_empty bool = true
}

pub fn (vs LocalVariableSymbol) str() string {
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return 'var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn (vs LocalVariableSymbol) str_ident(level int) string {
	ident := '  '.repeat(level)
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return '${ident}var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn new_empty_local_variable_symbol() LocalVariableSymbol {
	return symbols.LocalVariableSymbol{
		is_empty: true
		typ: undefined_symbol
	}
}

pub fn new_local_variable_symbol(mod string, name string, typ TypeSymbol, is_mut bool) LocalVariableSymbol {
	return symbols.LocalVariableSymbol{
		mod: mod
		name: name
		typ: typ
		is_mut: is_mut
		is_ref: is_mut || typ.is_ref
		is_empty: false
		id: rand.uuid_v4()
	}
}

pub struct GlobalVariableSymbol {
pub:
	name   string
	mod    string
	typ    TypeSymbol
	is_mut bool
	is_ref bool
	id     string
}

pub fn (vs GlobalVariableSymbol) str() string {
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return 'var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn (vs GlobalVariableSymbol) str_ident(level int) string {
	ident := '  '.repeat(level)
	mut_str := if vs.is_mut { 'mut ' } else { '' }
	return '${ident}var: $mut_str <$vs.name> ($vs.typ.name)'
}

pub fn new_global_variable_symbol(mod string, name string, typ TypeSymbol, is_mut bool) GlobalVariableSymbol {
	return symbols.GlobalVariableSymbol{
		mod: mod
		name: name
		typ: typ
		is_mut: is_mut
		is_ref: is_mut || typ.is_ref
		id: rand.uuid_v4()
	}
}
