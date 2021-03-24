import term
import strings
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
				'run'  { 
					command = .run 
					continue
				} 
				'test' { 
					command = .test 
					continue
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
				f := get_files(arg) ?
				files << f
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
	mut comp := comp.create_compilation(syntax_trees)

	if !(display_bound_stmts || display_lowered_stmts) {
		if use_evaluator {
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
				is_compiled_in_folder := syntax_trees.len > 1
				file := files[0]
				folder := os.dir(file)
				filename := os.file_name(file)

				out_filename := if is_compiled_in_folder {filename} else {filename[..filename.len-2]}
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
		
				llvm_backend := llvm.new_llvm_generator()
				res := comp.run(llvm_backend) 

				if res.result.len > 0 {
					write_diagnostics(res.result)
					exit(-1)
				}
				
				println(term.green('success'))
				exit(0)
			}
		}
	}
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
	mut iw := repl.IdentWriter{}
	for err in sorted_diagnosics {
		if err.has_loc == false {
			println('ERROR: $err.text')
			iw.write(term.red('error: '))
			iw.writeln(err.text)
			continue
		}
		source := err.location.source
		src := source.str()
		error_line_nr := source.line_nr(err.location.pos.pos)
		error_line := source.lines[error_line_nr - 1]
		error_col := err.location.pos.pos - error_line.start + 1

		mut line_nr_start := error_line_nr - 2
		if line_nr_start < 1 {
			line_nr_start = 1
		}

		error_line_nr_end := source.line_nr(err.location.pos.pos + err.location.pos.len)
		mut line_nr_end := error_line_nr_end + 2
		if line_nr_end > source.lines.len {
			line_nr_end = source.lines.len
		}

		
		mut err_end_pos := err.location.pos.pos + err.location.pos.len
		if err_end_pos > src.len {
			err_end_pos = src.len
		}

		iw.write('$err.location.source.filename:$error_line_nr:$error_col: ')
		iw.write(term.red('error: '))
		iw.writeln(err.text)

		mut b := strings.new_builder(0)
		nr_of_digits := line_nr_end.str().len
		for i in line_nr_start .. line_nr_end + 1 {
			line := source.lines[i - 1]
			nr_of_zeros_to_add := nr_of_digits - i.str().len
			if nr_of_zeros_to_add > 0 {
				b.write_string(' 0'.repeat(nr_of_zeros_to_add))
			} else {
				b.write_string(' ')
			}
			b.write_string('$i')
			b.write_string(' | ')
			if i == error_line_nr {
				prefix := src[line.start..err.location.pos.pos].replace('\t', '  ')
				error := src[err.location.pos.pos..err_end_pos].replace('\t', '  ')
				postfix := src[err.location.pos.pos + err.location.pos.len..line.start + line.len].replace('\t',
					'  ')

				b.write_string(prefix)
				b.write_string(term.red(error))
				b.writeln(postfix)
				b.write_string(' '.repeat(nr_of_digits + 1))
				b.write_string(' | ')
				b.writeln(term.red('${' '.repeat(prefix.len)}${'~'.repeat(err.location.pos.len)}'))
			} else {
				b.writeln(src[line.start..line.start + line.len].replace('\t', '  '))
			}
		}
		iw.writeln(b.str())
		iw.writeln('')
	}
	println(iw.str())
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
