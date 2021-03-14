module symbols

import rand
import lib.comp.symbols

pub struct LocalVariableSymbol {
pub:
	name   string
	typ    TypeSymbol
	is_mut bool
	id     string
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

pub fn new_local_variable_symbol(name string, typ TypeSymbol, is_mut bool) LocalVariableSymbol {
	return symbols.LocalVariableSymbol{
		name: name
		typ: typ
		is_mut: is_mut
		id: rand.uuid_v4()
	}
}

pub struct GlobalVariableSymbol {
pub:
	name   string
	typ    TypeSymbol
	is_mut bool
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

pub fn new_global_variable_symbol(name string, typ TypeSymbol, is_mut bool) GlobalVariableSymbol {
	return symbols.GlobalVariableSymbol{
		name: name
		typ: typ
		is_mut: is_mut
		id: rand.uuid_v4()
	}
}
