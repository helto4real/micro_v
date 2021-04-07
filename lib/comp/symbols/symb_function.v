module symbols

import rand
import lib.comp.util.source

pub const (
	undefined_fn = FunctionSymbol{
		name: ''
		id: 'undefined'
	}
)

pub struct FunctionSymbol {
pub:
	is_c_decl bool
	is_pub    bool
	location  source.TextLocation
	name      string
	typ       TypeSymbol
	receiver  LocalVariableSymbol
	params    []ParamSymbol
	id        string
}

pub fn (ts FunctionSymbol) == (rts FunctionSymbol) bool {
	return ts.id == rts.id
}

pub fn (ts FunctionSymbol) str() string {
	return ts.name
}

pub fn new_emtpy_function_symbol() FunctionSymbol {
	return FunctionSymbol{}
}

pub fn new_function_symbol(name string, params []ParamSymbol, typ TypeSymbol) FunctionSymbol {
	return FunctionSymbol{
		name: name
		params: params
		typ: typ
		id: rand.uuid_v4()
	}
}

pub fn new_function_symbol_from_decl(location source.TextLocation, receiver LocalVariableSymbol, name string, params []ParamSymbol, typ TypeSymbol, is_pub bool, is_c_decl bool) FunctionSymbol {
	return FunctionSymbol{
		location: location
		is_pub: is_pub
		is_c_decl: is_c_decl
		name: name
		receiver: receiver
		params: params
		typ: typ
		id: rand.uuid_v4()
	}
}

pub fn (ts FunctionSymbol) unique_name() string {
	if ts.receiver.is_empty {
		return ts.name
	} else {
		return ts.receiver.typ.unique_reciver_func_name(ts.name)
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
