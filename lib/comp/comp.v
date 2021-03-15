// comp module implements the compiler and evaluator 
module comp

import term
import lib.comp.ast
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
pub:
	is_script bool
pub mut:
	global_scope &binding.BoundGlobalScope
	syntax_trees []&ast.SyntaxTree
	print_fn     PrintFunc = print_fn // Defaults to stdout
	print_ref    voidptr
}

fn new_compilation(is_script bool, previous &Compilation, syntax_trees []&ast.SyntaxTree) &Compilation {
	return &Compilation{
		is_script: is_script
		previous: previous
		syntax_trees: syntax_trees
		global_scope: &binding.BoundGlobalScope(0)
	}
}

pub fn create_compilation(syntax_trees []&ast.SyntaxTree) &Compilation {
	return new_compilation(true, &Compilation(0), syntax_trees)
}

pub fn create_script(previous &Compilation, syntax_trees []&ast.SyntaxTree) &Compilation {
	return new_compilation(true, previous, syntax_trees)
}

pub fn (mut c Compilation) register_print_callback(print_fn PrintFunc, ref voidptr) {
	c.print_fn = print_fn
	c.print_ref = ref
}

pub fn (mut c Compilation) get_bound_global_scope() &binding.BoundGlobalScope {
	// TODO: Make this thread safe
	mut prev_glob_scope := &binding.BoundGlobalScope(0)
	if c.global_scope == 0 {
		if c.previous != 0 {
			prev_glob_scope = c.previous.global_scope
		}
		c.global_scope = binding.bind_global_scope(c.is_script, prev_glob_scope, c.syntax_trees)
	}
	return c.global_scope
}

pub fn (mut c Compilation) evaluate(vars &binding.EvalVariables) EvaluationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&util.source.Diagnostic{}
	for syntax in c.syntax_trees {
		result << syntax.log.all
	}
	result << global_scope.log.all
	if result.len > 0 {
		return new_evaluation_result(result, 0)
	}
	program := c.get_program()

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

fn (mut c Compilation) get_program() &binding.BoundProgram {
	global_scope := c.get_bound_global_scope()
	if c.previous == 0 {
		return binding.bind_program(c.is_script, &binding.BoundProgram(0), global_scope)
	} else {
		p := c.previous.get_program()
		return binding.bind_program(c.is_script, p, global_scope)
	}
}

pub fn (mut c Compilation) emit_tree(writer io.TermTextWriter, lower bool) {
	mut global_scope := c.get_bound_global_scope()
	program := c.get_program()
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
	result source.Diagnostic
	val    types.LitVal
}

pub fn new_evaluation_result(result []&util.source.Diagnostic, val types.LitVal) EvaluationResult {
	return EvaluationResult{
		result: result
		val: val
	}
}
