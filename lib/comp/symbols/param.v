module symbols

pub struct ParamSymbol {
pub:
	name   string
	typ    TypeSymbol
	is_mut bool
}

pub fn (ts ParamSymbol) == (rts ParamSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts ParamSymbol) str() string {
	return ts.name
}

pub fn new_param_symbol(name string, typ TypeSymbol, is_mut bool) ParamSymbol {
	return ParamSymbol{

		name: name
		typ: typ
		is_mut: is_mut
	}
}
