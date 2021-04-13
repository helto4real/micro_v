// comp module implements the compiler and evaluator
module comp

import term
import lib.comp.ast
import lib.comp.binding
import lib.comp.util.source
import lib.comp.util.pref
import lib.comp.io
import lib.comp.symbols
import lib.comp.gen

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
	is_test   bool
pub mut:
	global_scope &binding.BoundGlobalScope
	syntax_trees []&ast.SyntaxTree
	print_fn     PrintFunc = print_fn // Defaults to stdout
	print_ref    voidptr
}

fn new_compilation(is_test bool, is_script bool, previous &Compilation, syntax_trees []&ast.SyntaxTree) &Compilation {
	return &Compilation{
		is_test: is_test
		is_script: is_script
		previous: previous
		syntax_trees: syntax_trees
		global_scope: &binding.BoundGlobalScope(0)
	}
}

pub fn create_compilation(syntax_trees []&ast.SyntaxTree) &Compilation {
	return new_compilation(false, false, &Compilation(0), syntax_trees)
}

pub fn create_script(previous &Compilation, syntax_trees []&ast.SyntaxTree) &Compilation {
	return new_compilation(false, true, previous, syntax_trees)
}

pub fn create_test(syntax_trees []&ast.SyntaxTree) &Compilation {
	return new_compilation(true, false, &Compilation(0), syntax_trees)
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
	mut result := []&source.Diagnostic{}
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

pub fn (mut c Compilation) gen(back_end gen.Generator, pref pref.CompPref) CompilationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&source.Diagnostic{}
	for syntax in c.syntax_trees {
		result << syntax.log.all
	}
	result << global_scope.log.all
	if result.len > 0 {
		return new_compilation_result(result)
	}
	program := c.get_program()

	if program.log.all.len > 0 {
		return new_compilation_result(program.log.all)
	}
	diagnostics := back_end.generate(pref, program)
	return new_compilation_result(diagnostics.all)
}

pub fn (mut c Compilation) run(back_end gen.Generator, pref pref.CompPref) CompilationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&source.Diagnostic{}
	for syntax in c.syntax_trees {
		result << syntax.log.all
	}
	result << global_scope.log.all
	if result.len > 0 {
		return new_compilation_result(result)
	}
	program := c.get_program()

	if program.log.all.len > 0 {
		return new_compilation_result(program.log.all)
	}
	diagnostics := back_end.run(program, pref)
	return new_compilation_result(diagnostics.all)
}

pub fn (mut c Compilation) run_tests(back_end gen.Generator) CompilationResult {
	mut global_scope := c.get_bound_global_scope()
	mut result := []&source.Diagnostic{}
	for syntax in c.syntax_trees {
		result << syntax.log.all
	}
	result << global_scope.log.all
	if result.len > 0 {
		return new_compilation_result(result)
	}
	program := c.get_program()

	if program.log.all.len > 0 {
		return new_compilation_result(program.log.all)
	}
	diagnostics := back_end.run_tests(program)
	return new_compilation_result(diagnostics.all)
}

fn (mut c Compilation) get_program() &binding.BoundProgram {
	global_scope := c.get_bound_global_scope()
	if c.previous == 0 {
		return binding.bind_program(c.is_test, c.is_script, &binding.BoundProgram(0),
			global_scope)
	} else {
		p := c.previous.get_program()
		return binding.bind_program(c.is_test, c.is_script, p, global_scope)
	}
}

pub fn (mut c Compilation) emit_tree(writer io.TermTextWriter, lower bool) {
	global_scope := c.get_bound_global_scope()
	if global_scope.main_func != symbols.undefined_fn {
		c.emit_tree_for_function(writer, c.global_scope.main_func, lower)
	} else if global_scope.script_func != symbols.undefined_fn {
		c.emit_tree_for_function(writer, c.global_scope.script_func, lower)
	}
}

pub fn (mut c Compilation) emit_tree_for_function(writer io.TermTextWriter, function symbols.FunctionSymbol, lower bool) {
	program := c.get_program()
	symbols.write_symbol(writer, function)
	body := program.func_bodies[function.id]
	if lower {
		lowered_body := binding.lower(body)
		binding.write_node(writer, binding.BoundStmt(lowered_body))
	} else {
		binding.write_node(writer, binding.BoundStmt(body))
	}
}

pub struct EvaluationResult {
pub:
	result []&source.Diagnostic
	val    symbols.LitVal
}

pub fn new_evaluation_result(result []&source.Diagnostic, val symbols.LitVal) EvaluationResult {
	return EvaluationResult{
		result: result
		val: val
	}
}

pub struct CompilationResult {
pub:
	result []&source.Diagnostic
	val    symbols.LitVal
}

pub fn new_compilation_result(result []&source.Diagnostic) CompilationResult {
	return CompilationResult{
		result: result
	}
}
