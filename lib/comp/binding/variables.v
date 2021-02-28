module binding
import lib.comp.types
import lib.comp.symbols

[heap]
pub struct EvalVariables {
mut:
	vars map[voidptr]types.LitVal
}

pub fn new_eval_variables() &EvalVariables {
	return &EvalVariables{}
}

pub fn (mut ev EvalVariables) assign_variable_value(var &symbols.VariableSymbol, val types.LitVal) {
	ev.vars[var] = val
}

pub fn (mut ev EvalVariables) lookup(var &symbols.VariableSymbol) ?types.LitVal {
	val := ev.vars[var] or { return none }
	return val
}
