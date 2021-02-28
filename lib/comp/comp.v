// comp module implements the compiler and evaluator 
module comp
import term
import lib.comp.parser
import lib.comp.binding
import lib.comp.types
import lib.comp.util
import lib.comp.lowering

[heap]
pub struct Compilation {
mut:
	previous     &Compilation
pub mut:
	global_scope &binding.BoundGlobalScope
	syntax parser.SyntaxTree
}

pub fn new_compilation(syntax_tree parser.SyntaxTree) &Compilation {
	return &Compilation{
		syntax: syntax_tree
		global_scope: &binding.BoundGlobalScope(0)
		previous: &Compilation(0)
	}
}

fn new_compilation_with_previous(previous &Compilation, syntax_tree parser.SyntaxTree) &Compilation {
	return &Compilation{
		syntax: syntax_tree
		global_scope: &binding.BoundGlobalScope(0)
		previous: previous
	}
}

pub fn (mut c Compilation) get_statement() binding.BoundBlockStmt {
	result := c.get_bound_global_scope().stmt
	lower := lowering.lower(result)
	return lower

}

pub fn (mut c Compilation) get_bound_global_scope() &binding.BoundGlobalScope {
	// TODO: Make this thread safe
	mut prev_glob_scope := &binding.BoundGlobalScope(0)
	if c.global_scope == 0 {
		// println('${voidptr(c.previous)}')
		if c.previous != 0 {
			prev_glob_scope = c.previous.global_scope
		}
		c.global_scope = binding.bind_global_scope(prev_glob_scope, c.syntax.root)
	}
	return c.global_scope
}

pub fn (c &Compilation) continue_with(syntax_tree parser.SyntaxTree) &Compilation {
	return new_compilation_with_previous(c, syntax_tree)
}

pub fn (mut c Compilation) evaluate(vars &binding.EvalVariables) EvaluationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&util.Diagnostic{}
	result << c.syntax.log.all
	result << global_scope.log.all
	if result.len > 0 {
		return new_evaluation_result(result, 0)
	}
	stmt := c.get_statement()
	mut evaluator := new_evaluator(stmt, vars)
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
