module symbols

pub struct FunctionSymbol {
pub:
	name   string
	typ    TypeSymbol
	params []ParamSymbol
}

pub fn (ts FunctionSymbol) == (rts FunctionSymbol) bool {
	return ts.name == rts.name
}

pub fn (ts FunctionSymbol) str() string {
	return ts.name
}

pub fn new_function_symbol(name string, params []ParamSymbol, typ TypeSymbol) FunctionSymbol {
	return FunctionSymbol{
		name: name
		params: params
		typ: typ
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
