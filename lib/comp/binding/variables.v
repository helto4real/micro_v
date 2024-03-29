module binding

import lib.comp.symbols

[heap]
pub struct EvalVariables {
mut:
	vars map[string]symbols.LitVal
}

pub fn new_eval_variables() &EvalVariables {
	return &EvalVariables{
		vars: map[string]symbols.LitVal{}
	}
}

pub fn (mut ev EvalVariables) assign_variable_value(var symbols.VariableSymbol, val symbols.LitVal) {
	ev.vars[var.id] = val
}

pub fn (mut ev EvalVariables) lookup(var symbols.VariableSymbol) ?symbols.LitVal {
	val := ev.vars[var.id] or { return none }
	return val
}

struct EvalVarsStack {
mut:
	size     int
	elements []&EvalVariables
}

pub fn new_eval_vars_stack() EvalVarsStack {
	return EvalVarsStack{}
}

[inline]
pub fn (stack EvalVarsStack) is_empty() bool {
	return stack.size <= 0
}

[inline]
pub fn (stack EvalVarsStack) len() int {
	return stack.elements.len
}

pub fn (stack EvalVarsStack) peek() ?&EvalVariables {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	} else {
		return none
	}
}

pub fn (mut stack EvalVarsStack) pop() ?&EvalVariables {
	if !stack.is_empty() {
		val := stack.elements[stack.size - 1]
		stack.size--
		return val
	}
	return none
}

pub fn (mut stack EvalVarsStack) push(item &EvalVariables) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}
