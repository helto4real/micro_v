// comp module implements the compiler and evaluator 
module comp

import term
import lib.comp.parser
import lib.comp.binding
import lib.comp.types
import lib.comp.util

[heap]
pub struct Compilation {
mut:
	previous &Compilation
	global_scope &binding.BoundGlobalScope
pub mut:
	syntax parser.SyntaxTree
}

pub fn new_compilation(syntax_tree parser.SyntaxTree) &Compilation {
	return &Compilation{
		syntax: syntax_tree
		global_scope: &binding.BoundGlobalScope(0)
		previous: &Compilation(0)
	}
}

pub fn new_compilation_with_previous(previous &Compilation, syntax_tree parser.SyntaxTree) &Compilation {
	return &Compilation{
		syntax: syntax_tree
		global_scope: &binding.BoundGlobalScope(0)
		previous: previous
	}
}

pub fn (mut c Compilation) get_bound_global_scope() &binding.BoundGlobalScope {
	// TODO: Make this thread safe
	if c.global_scope == 0 {
		prev_glob_scope := if c.previous != 0 {c.previous.global_scope} else {&binding.BoundGlobalScope(0)}
		c.global_scope = binding.bind_global_scope(prev_glob_scope, c.syntax.root)	
	}
	return c.global_scope
}

pub fn (mut c Compilation) continue_with(syntax_tree parser.SyntaxTree) &Compilation {
	return new_compilation_with_previous(c, syntax_tree)
}

pub fn (mut c Compilation) evaluate(vars &EvalVariables) EvaluationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&util.Diagnostic{}
	result << c.syntax.log.all
	result << global_scope.log.all
	if result.len > 0 {
		return new_evaluation_result(result, 0)
	}
	mut evaluator := new_evaluator(global_scope.expr, vars)
	val := evaluator.evaluate() or {
		println(term.fail_message('Error in eval: $err'))
		0
	}
	return new_evaluation_result(result, val)
}

pub struct EvaluationResult {
pub:
	result []&util.Diagnostic
	val    types.LitVal
}

pub fn new_evaluation_result(result []&util.Diagnostic, val types.LitVal) EvaluationResult {
	return EvaluationResult{
		result: result
		val: val
	}
}
