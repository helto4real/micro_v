// comp module implements the compiler and evaluator 
module comp

import term
import lib.comp.parser
import lib.comp.binding
import lib.comp.types
import lib.comp.util.source
import lib.comp.io
import lib.comp.symbols

pub type PrintFunc = fn (text string, nl bool, ref voidptr)

pub fn print_fn(text string, nl bool, ref voidptr) {
	if nl {
		println(text)
	} else {
		print(text)
	}
}

[heap]
pub struct Compilation {
mut:
	previous &Compilation
pub mut:
	global_scope &binding.BoundGlobalScope
	syntax       parser.SyntaxTree
	print_fn     PrintFunc = print_fn // Defaults to stdout
	print_ref    voidptr
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

pub fn (mut c Compilation) register_print_callback(print_fn PrintFunc, ref voidptr) {
	c.print_fn = print_fn
	c.print_ref = ref
}

// pub fn (mut c Compilation) get_statement() binding.BoundBlockStmt {
// 	result := c.get_bound_global_scope().stmt
// 	lower := lowering.lower(result)
// 	return lower
// }

pub fn (mut c Compilation) get_bound_global_scope() &binding.BoundGlobalScope {
	// TODO: Make this thread safe
	mut prev_glob_scope := &binding.BoundGlobalScope(0)
	if c.global_scope == 0 {
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
	mut result := []&source.Diagnostic{}
	result << c.syntax.log.all
	result << global_scope.log.all
	if result.len > 0 {
		return new_evaluation_result(result, 0)
	}
	program := binding.bind_program(global_scope)

	if program.log.all.len > 0 {
		return new_evaluation_result(program.log.all, 0)
	}

	mut evaluator := new_evaluator(program, vars)
	evaluator.register_print_callback(c.print_fn, c.print_ref)
	val := evaluator.evaluate() or {
		println(term.fail_message('Error in eval: $err'))
		0
	}
	return new_evaluation_result(result, val)
}

pub fn (mut c Compilation) emit_tree(writer io.TermTextWriter, lower bool) {
	mut global_scope := c.get_bound_global_scope()
	program := binding.bind_program(global_scope)
	if lower {
		if program.stmt.bound_stmts.len > 0 {
			lowered_stmt := binding.lower(program.stmt)
			binding.write_node(writer, binding.BoundStmt(lowered_stmt))
		} else {
			for key, fbody in program.func_bodies {
				func := global_scope.funcs.filter(it.id == key)
				if func.len == 0 {
					continue
				}
				symbols.write_symbol(writer, func[0])
				lowered_stmt := binding.lower(fbody)
				binding.write_node(writer, binding.BoundStmt(lowered_stmt))
			}
		}
	} else {
		if program.stmt.bound_stmts.len > 0 {
			binding.write_node(writer, binding.BoundStmt(program.stmt))
		} else {
			for key, fbody in program.func_bodies {
				func := global_scope.funcs.filter(it.id == key)
				if func.len == 0 {
					continue
				}
				symbols.write_symbol(writer, func[0])
				binding.write_node(writer, binding.BoundStmt(fbody))
			}
		}
	}
}

pub struct EvaluationResult {
pub:
	result []&source.Diagnostic
	val    types.LitVal
}

pub fn new_evaluation_result(result []&source.Diagnostic, val types.LitVal) EvaluationResult {
	return EvaluationResult{
		result: result
		val: val
	}
}
