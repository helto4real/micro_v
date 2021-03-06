module symbols

import rand

pub const (
	undefined_fn = FunctionSymbol{}
)

pub struct FunctionSymbol {
pub:
	name   string
	typ    TypeSymbol
	params []ParamSymbol
	id     string
}

pub fn (ts FunctionSymbol) == (rts FunctionSymbol) bool {
	return ts.id == rts.id
}

pub fn (ts FunctionSymbol) str() string {
	return ts.name
}

pub fn new_function_symbol(name string, params []ParamSymbol, typ TypeSymbol) FunctionSymbol {
	return FunctionSymbol{
		name: name
		params: params
		typ: typ
		id: rand.uuid_v4()
	}
}

pub fn lookup_built_in_function(name string) ?FunctionSymbol {
	for f in built_in_functions {
		if f.name == name {
			return f
		}
	}
	return none
}
