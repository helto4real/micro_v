import term
import lib.repl
import os
import lib.comp
import lib.comp.ast
import lib.comp.binding
import lib.comp.parser
import lib.comp.symbols
import lib.comp.util.mod
import lib.comp.util.source
// import lib.comp.gen.golang
import lib.comp.gen.llvm

enum Command {
	build
	run
	test
	test_self
}

struct VCommand {
mut:
	imported_syntax_trees []&ast.SyntaxTree
	imported_paths []string
	has_errors bool
	mod_cache &mod.ModuleCache
	start_folder string
}
fn new_v_command() VCommand {
	return VCommand{
		mod_cache: mod.get_mod_cache()
	}
}

fn main() {
	mut cmd := new_v_command()
	cmd.run() ?
}

fn (mut vc VCommand) run() ? {
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
					files << vc.get_self_test_files() ?
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
				v_files := vc.get_files(arg) ?
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
	// add the runtime files
	runtime_files := get_runtime_files() ?
	files << runtime_files

	mut syntax_trees := []&ast.SyntaxTree{cap: files.len}
	for file in files {
		syntax_tree := parser.parse_syntax_tree_from_file(file) ?
		syntax_trees << syntax_tree
		if syntax_tree.log.all.len > 0 {
			write_diagnostics(syntax_tree.log.all)
		}
		vc.has_errors = vc.has_errors || syntax_tree.log.all.len > 0
	}
	if vc.has_errors {
		exit(-1)
	}
	// parse the imported files 
	
	vc.parse_imports(mut syntax_trees) ?

	syntax_trees << vc.imported_syntax_trees

	for syntax_tree in syntax_trees {
		mut mut_syntax_tree := syntax_tree // v bug need this
		file_path := syntax_tree.source.filename
		mut module_name := syntax_tree.mod
		if module_name.len == 0 {
			// main module
			mut_syntax_tree.mod = 'main'
		} else {
			real_mod := vc.mod_cache.lookup_full_module_name(vc.start_folder, file_path, module_name)
			mut_syntax_tree.mod = real_mod
		}

	}

	if vc.has_errors {
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
				is_compiled_in_folder := syntax_trees.len - runtime_files.len - vc.imported_syntax_trees.len > 1
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
	mut comp := comp.create_script(&comp.Compilation(0), syntax_trees)
	mut iw := repl.IdentWriter{}
	if display_bound_stmts {
		comp.emit_tree(iw, false)
	} else {
		comp.emit_tree(iw, true)
	}
	println(iw.str())
}

fn (mut vc VCommand) parse_imports(mut syntax_trees []&ast.SyntaxTree) ? {
	for syntax in syntax_trees {
		mut mut_syntax := syntax // v bug requires this
		for imported in syntax.imports {
			name := imported.name_expr.name_tok.lit
			filename := syntax.source.filename
			path := vc.mod_cache.lookup_module_path_by_file(filename, name)
			if path.len == 0 {
				mut_syntax.log.error_cannot_find_module(imported.name_expr.text_location())
				write_diagnostics(syntax.log.all)
				break
			}
			if path in vc.imported_paths {
				// path already imported
				continue
			}
			files := vc.get_files(path) ? {
				for f in files {
					syntax_tree := parser.parse_syntax_tree_from_file(f) ?
					vc.imported_syntax_trees << syntax_tree
					vc.imported_paths << path
					if syntax_tree.log.all.len > 0 {
						write_diagnostics(syntax_tree.log.all)
					}
					vc.has_errors = vc.has_errors || syntax_tree.log.all.len > 0

				}
			}
		}
	}
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

fn (mut vc VCommand) get_files(file_or_directory string) ?[]string {
	mut result := []string{}
	if os.is_dir(file_or_directory) {
		vc.start_folder = os.real_path(file_or_directory)
		files := os.ls(file_or_directory) ?
		v_files := files.filter(it.ends_with('.v'))
		for v_file in v_files {
			result << os.join_path(file_or_directory, v_file)
		}
	} else {
		vc.start_folder = os.dir(os.real_path(file_or_directory))
		result << file_or_directory
	}
	return result
}
fn get_runtime_files() ?[]string {
	exe_directory_path := os.dir(os.executable())
	base_dir := exe_directory_path[..exe_directory_path.len - 6]
	path_to_runtime := os.join_path(base_dir, 'lib/runtime')
	test_files := os.walk_ext(path_to_runtime, '.v')
	if test_files.len > 0 {
		return test_files
	}
	return error('no runtime files found in path $path_to_runtime')
}

fn (mut vc VCommand) get_self_test_files() ?[]string {
	exe_directory_path := os.dir(os.executable())
	base_dir := exe_directory_path[..exe_directory_path.len - 6]
	path_to_tests := os.join_path(base_dir, 'tests')
	vc.start_folder = os.dir(os.real_path(path_to_tests))
	test_files := os.walk_ext(path_to_tests, '.v')
	if test_files.len > 0 {
		return test_files
	}
	return error('no self test files found in path $path_to_tests')
}

