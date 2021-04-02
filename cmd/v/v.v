import term
import lib.repl
import os
import lib.comp
import lib.comp.ast
import lib.comp.binding
import lib.comp.parser
import lib.comp.symbols
import lib.comp.util.source
// import lib.comp.gen.golang
import lib.comp.gen.llvm

enum Command {
	build
	run
	test
	test_self
}

fn main() {
	args := os.args[1..]
	if args.len == 0 {
		repl.run() ?
		exit(0)
	}
	if args[0] == 'help' {
		display_help_message(args)
		exit(0)
	}
	mut files := []string{}
	mut display_bound_stmts := false
	mut display_lowered_stmts := false
	mut use_evaluator := false
	mut command := Command.build
	for i, arg in args {
		if i == 0 {
			match arg {
				'run' {
					command = .run
					continue
				}
				'test' {
					command = .test
					continue
				}
				'test-self' {
					command = .test_self
					files << get_self_test_files() ?
					break
				}
				'build' {
					command = .build
					continue
				}
				else {}
			}
		}
		match arg {
			'-display_stmts' {
				display_bound_stmts = true
			}
			'-display_lower' {
				display_lowered_stmts = true
			}
			'-eval' {
				use_evaluator = true
			}
			else {
				v_files := get_files(arg) ?
				for v_file in v_files {
					if command == .test {
						files << v_file
					} else if !v_file.ends_with('_test.v') {
						files << v_file
					}
				}
			}
		}
	}
	if files.len == 0 {
		eprintln(term.red('no file specified'))
		exit(-1)
	}
	mut syntax_trees := []&ast.SyntaxTree{cap: files.len}
	mut has_errors := false
	for file in files {
		syntax_tree := parser.parse_syntax_tree_from_file(file) ?
		syntax_trees << syntax_tree
		if syntax_tree.log.all.len > 0 {
			write_diagnostics(syntax_tree.log.all)
		}
		has_errors = has_errors || syntax_tree.log.all.len > 0
	}
	if has_errors {
		exit(-1)
	}

	if !(display_bound_stmts || display_lowered_stmts) {
		if use_evaluator {
			mut comp := comp.create_compilation(syntax_trees)
			vars := binding.new_eval_variables()
			res := comp.evaluate(vars)
			if res.result.len == 0 {
				if res.val !is symbols.None {
					println(term.yellow(res.val.str()))
				}
				println(term.cyan('OK'))
				exit(0)
			}
			write_diagnostics(res.result)
			exit(-1)
		} else {
			if command == .build {
				mut comp := comp.create_compilation(syntax_trees)
				is_compiled_in_folder := syntax_trees.len > 1
				file := files[0]
				folder := os.dir(file)
				filename := os.file_name(file)

				out_filename := if is_compiled_in_folder {
					filename
				} else {
					filename[..filename.len - 2]
				}
				out_path := os.join_path(folder, out_filename)

				llvm_backend := llvm.new_llvm_generator()
				res := comp.gen(llvm_backend, out_path)

				if res.result.len > 0 {
					write_diagnostics(res.result)
					exit(-1)
				}

				println(term.green('success'))
				exit(0)
			} else if command == .run {
				mut comp := comp.create_compilation(syntax_trees)
				llvm_backend := llvm.new_llvm_generator()
				res := comp.run(llvm_backend)

				if res.result.len > 0 {
					write_diagnostics(res.result)
					exit(-1)
				}

				println(term.green('success'))
				exit(0)
			} else if command == .test || command == .test_self {
				mut comp := comp.create_test(syntax_trees)
				llvm_backend := llvm.new_llvm_generator()
				res := comp.run_tests(llvm_backend)

				if res.result.len > 0 {
					write_diagnostics(res.result)
					exit(-1)
				}

				println(term.green('test success'))
				println('')
				exit(0)
			}
		}
	}
	mut comp := comp.create_compilation(syntax_trees)
	mut iw := repl.IdentWriter{}
	if display_bound_stmts {
		comp.emit_tree(iw, false)
	} else {
		comp.emit_tree(iw, true)
	}
	println(iw.str())
}

fn display_help_message(args []string) {
	println('
Mini V (mv) is a minimal implmentation of V lang
Usage:
	mv help                     Displays this message
	mv hello.v                  Compiles the hello.v file
	mv -display_stmts hello.v   Diplay ast statements
	mv -display_lower hello.v   Diplay ast statements (lowered)
	mv                          Starts the repl	
	')
}

pub fn write_diagnostics(diagnostics []&source.Diagnostic) {
	mut sorted_diagnosics := []&source.Diagnostic{cap: diagnostics.len}
	sorted_diagnosics << diagnostics
	sorted_diagnosics.sort(a.location.pos.pos < b.location.pos.pos)
	mut sw := source.SourceWriter{}
	for err in sorted_diagnosics {
		if err.has_loc == false {
			sw.write(term.red('error: '))
			sw.writeln(err.text)
			continue
		}
		source.write_diagnostic(mut sw, err.location, err.text, 2)
	}
	println(sw.str())
}

fn get_self_test_files() ?[]string {
	exe_directory_path := os.dir(os.executable())
	base_dir := exe_directory_path[..exe_directory_path.len - 6]
	path_to_tests := os.join_path(base_dir, 'lib/tests')
	test_files := os.walk_ext(path_to_tests, '.v')
	if test_files.len > 0 {
		return test_files
	}
	return none
}

fn get_files(file_or_directory string) ?[]string {
	mut result := []string{}
	if os.is_dir(file_or_directory) {
		files := os.ls(file_or_directory) ?
		v_files := files.filter(it.ends_with('.v'))
		for v_file in v_files {
			result << os.join_path(file_or_directory, v_file)
		}
	} else {
		result << file_or_directory
	}
	return result
}
