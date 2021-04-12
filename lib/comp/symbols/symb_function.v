module symbols

import rand
import lib.comp.util.source

pub const (
	undefined_fn = FunctionSymbol{
		mod: 'lib.runtime'
		name: 'undefined'
		id: 'undefined'
	}
)

pub struct FunctionSymbol {
pub:
	is_c_decl bool
	is_pub    bool
	location  source.TextLocation
	mod       string
	name      string
	typ       TypeSymbol
	receiver  LocalVariableSymbol
	params    []ParamSymbol
	id        string
}

pub fn (ts FunctionSymbol) str() string {
	return ts.unique_fn_name()
}

pub fn new_emtpy_function_symbol() FunctionSymbol {
	return FunctionSymbol{}
}

pub fn new_function_symbol(mod string, name string, params []ParamSymbol, typ TypeSymbol) FunctionSymbol {
	return FunctionSymbol{
		mod: mod
		name: name
		params: params
		typ: typ
		id: rand.uuid_v4()
	}
}

pub fn new_function_symbol_from_decl(location source.TextLocation, mod string, receiver LocalVariableSymbol, name string, params []ParamSymbol, typ TypeSymbol, is_pub bool, is_c_decl bool) FunctionSymbol {
	return FunctionSymbol{
		location: location
		mod: mod
		is_pub: is_pub
		is_c_decl: is_c_decl
		name: name
		receiver: receiver
		params: params
		typ: typ
		id: rand.uuid_v4()
	}
}

pub fn (ts FunctionSymbol) unique_fn_name() string {
	if ts.receiver.is_empty {
		return '${ts.mod}.$ts.name'
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
