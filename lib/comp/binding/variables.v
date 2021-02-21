module binding

import lib.comp.types

[heap]
pub struct VariableSymbol {
pub:
	name   string
	typ    types.Type
	is_mut bool
}

pub fn (vs &VariableSymbol) str() string {
	mut_str := if vs.is_mut {'mut '} else {''}
	return 'var: $mut_str <$vs.name> ($vs.typ.typ_str())'
}

pub fn (vs &VariableSymbol) str_ident(level int) string {
	ident := '  '.repeat(level)
	mut_str := if vs.is_mut {'mut '} else {''}
	return '${ident}var: $mut_str <$vs.name> ($vs.typ.typ_str())'
}

pub fn new_variable_symbol(name string, typ types.Type, is_mut bool) &VariableSymbol {
	return &VariableSymbol {
		name: name
		typ: typ
		is_mut: is_mut
	}
}

[heap]
pub struct EvalVariables {
mut:
	vars map[voidptr]types.LitVal
}

pub fn new_eval_variables() &EvalVariables {
	return &EvalVariables{}
}

pub fn (mut ev EvalVariables) assign_variable_value(var &VariableSymbol, val types.LitVal) {
	ev.vars[var] = val
}

pub fn (mut ev EvalVariables) lookup(var &VariableSymbol) ?types.LitVal {
	val := ev.vars[var] or {
		return none
	}
	return val
}