// comp module implements the compiler and evaluator 
module comp

import term
import lib.comp.parser
import lib.comp.binding
import lib.comp.types
import lib.comp.util

pub struct Compilation {
pub mut:
	syntax parser.SyntaxTree
}

pub fn new_compilation(syntax_tree parser.SyntaxTree) &Compilation {
	return &Compilation{
		syntax: syntax_tree
	}
}

pub fn (mut c Compilation) evaluate() EvaluationResult {
	mut binder := binding.new_binder()
	bounded_expr := binder.bind_expr(c.syntax.root)
	mut result := []util.Diagnostic{}
	result << c.syntax.log.all
	result << binder.log.all
	if result.len > 0 {
		return new_evaluation_result(result, 0)
	}
	mut evaluator := new_evaluator(bounded_expr)
	val := evaluator.evaluate() or {
		println(term.fail_message('Error in eval: $err'))
		0
	}
	return new_evaluation_result(result, val)
}

pub struct EvaluationResult {
pub:
	result []util.Diagnostic
	val    types.LitVal
}

pub fn new_evaluation_result(result []util.Diagnostic, val types.LitVal) EvaluationResult {
	return EvaluationResult{
		result: result
		val: val
	}
}
