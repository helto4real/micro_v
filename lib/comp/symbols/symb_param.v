module symbols

import rand

pub struct ParamSymbol {
pub:
	name        string
	typ         TypeSymbol
	is_mut      bool
	is_variadic bool
	id          string
	is_ref      bool
}

pub fn (ts ParamSymbol) == (rts ParamSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts ParamSymbol) str() string {
	return ts.name
}

pub fn (ts ParamSymbol) str_ident(level int) string {
	ident := '  '.repeat(level)
	mut_str := if ts.is_mut { 'mut ' } else { '' }
	return '${ident}var: $mut_str <$ts.name> ($ts.typ.name)'
}

pub fn new_param_symbol(name string, typ TypeSymbol, is_mut bool, is_variadic bool, is_ref bool) ParamSymbol {
	return ParamSymbol{
		name: name
		typ: typ
		is_mut: is_mut
		is_variadic: is_variadic
		is_ref: is_mut || typ.is_ref
		id: rand.uuid_v4()
	}
}
