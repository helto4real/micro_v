import term
import strings
import lib.repl
import os
import lib.comp.types
import lib.comp.binding
import lib.comp.parser
import lib.comp.util.source
import lib.comp

fn main() {
	args := os.args[1..]
	if args.len == 0 {
		repl.run() ?
		exit(0)
	}
	if args[0]=='help' {
		display_help_message(args)
		exit(0)
	}
	mut file := ''
	mut display_bound_stmts := false
	mut display_lowered_stmts := false
	for arg in args {
		match arg {
			'-display_stmts' {
				display_bound_stmts = true
			}
			'-display_lower' {
				display_lowered_stmts = true
			}
			else {
				if file.len > 0 {
					eprintln(term.red('you can only specify one file or folder'))
					exit(-1)
				}
				file = arg
			}
		}
	}
	if file.len == 0 {
		eprintln(term.red('no file specified'))
		exit(-1)
	}
	syntax_tree := parser.parse_syntax_tree_from_file(file) ?
	if syntax_tree.log.all.len > 0 {
		// write_diagnostics(syntax_tree.log.all, syntax_tree)
		exit(-1)
	}
	mut comp := comp.new_compilation(syntax_tree)

	if !(display_bound_stmts || display_lowered_stmts) {
		vars := binding.new_eval_variables()
		res := comp.evaluate(vars)
		if res.result.len == 0 {
			if res.val !is types.None {
				println(term.yellow(res.val.str()))
			}
			println(term.cyan('OK'))
			exit(0)
		}
		write_diagnostics(file, res.result, syntax_tree)
		exit(-1)
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
pub fn write_diagnostics(filename string, diagnostics []&source.Diagnostic, syntax_tree parser.SyntaxTree) {
	mut sorted_diagnosics := []&source.Diagnostic{cap: diagnostics.len}
	sorted_diagnosics << diagnostics
	sorted_diagnosics.sort(a.pos.pos < b.pos.pos)
	mut iw := repl.IdentWriter{}
	for err in sorted_diagnosics {
		src := syntax_tree.source.str()
		error_line_nr := syntax_tree.source.line_nr(err.pos.pos)
		error_line := syntax_tree.source.lines[error_line_nr-1]
		error_col := err.pos.pos - error_line.start + 1

		mut line_nr_start := error_line_nr-2
		if line_nr_start < 1 {line_nr_start = 1}

		error_line_nr_end := syntax_tree.source.line_nr(err.pos.pos + err.pos.len)
		// line_end := syntax_tree.source.lines[error_line_nr_end-1]

		mut line_nr_end := error_line_nr_end + 2
		if line_nr_end > syntax_tree.source.lines.len {
			line_nr_end = syntax_tree.source.lines.len
		}

		mut err_end_pos := err.pos.pos + err.pos.len
		if err_end_pos > src.len {
			err_end_pos = src.len
		}
		
		iw.write('${filename}:${error_line_nr}:${error_col}: ')
		iw.write(term.red('error: '))
		iw.writeln(err.text)

		mut b:=strings.new_builder(0)
		nr_of_digits := line_nr_end.str().len
		for i in line_nr_start..line_nr_end {
			line := syntax_tree.source.lines[i-1]
			nr_of_zeros_to_add := nr_of_digits - i.str().len 
			if nr_of_zeros_to_add > 0 {
				b.write_string(' 0'.repeat(nr_of_zeros_to_add))
			} else {
				b.write_string(' ')
			}
			b.write_string('${i}')
			b.write_string(' | ')
			if i == error_line_nr {
				prefix := src[line.start..err.pos.pos].replace('\t', '  ')
				error := src[err.pos.pos..err_end_pos].replace('\t', '  ')
				postfix := src[err.pos.pos+err.pos.len..line.start+line.len].replace('\t', '  ')

				
				b.write_string(prefix)
				b.write_string(term.red(error))
				b.writeln(postfix)
				b.write_string(' '.repeat(nr_of_digits+1))
				b.write_string(' | ')
				b.writeln(term.red('${' '.repeat(prefix.len)}${'~'.repeat(err.pos.len)}'))
			} else {
				b.writeln(src[line.start..line.start+line.len].replace('\t', '  '))
			}
		}
		iw.writeln(b.str())
		iw.writeln('')

		// iw.writeln('')
		// iw.write(prefix.trim('\r\n'))
		// iw.write(term.red(error))
		// iw.writeln(postfix)
		// iw.writeln('')
	}
	println(iw.str())
}

// fn tokenizer() {
// 	for {
// 		print('tokens> ')
// 		line := os.get_line()
// 		if line == '' {
// 			break
// 		}
// 		mut tnz := token.new_tokenizer_from_string(line)
// 		mut tokens := tnz.scan_all()
// 		for _, token in tokens {
// 			println(token)
// 			if token.kind == .eof {
// 				break
// 			}
// 		}
// 	}
// }

// Keeping this to debug

// 	syntax_tree := parser.parse_syntax_tree(
// 		'
// 		    {
// 				if true {100} else {200}
// 			}
// 			')
// 	// syntax_tree := parser.parse_syntax_tree(
// 	// 	'
// 	// 	    {
// 	// 			mut a := 0
// 	// 			mut b := 0
// 	// 			for a < 5{
// 	// 				b = b - 1
// 	// 				a = a + 1

// 	// 			}
// 	// 			b
// 	// 		}
// 	// 		')
// 	if syntax_tree.log.all.len > 0 {
// 		println('syntax error')
// 		return
// 	}
// 	vars :=  binding.new_eval_variables()
// 	tree := walker.print_expression(syntax_tree.root)
// 	println(tree)
// 	mut comp := comp.new_compilation(syntax_tree)
// 	res := comp.evaluate(vars)
// 	println('RES: $res')
// }

// fn evaluate(expr string) comp.EvaluationResult {
// 	syntax_tree := parser.parse_syntax_tree(expr)

// 	if syntax_tree.log.all.len > 0 {
// 		eprintln('expression error: $expr')
// 		assert syntax_tree.log.all.len == 0
// 	}

// 	mut comp := comp.new_compilation(syntax_tree)
// 	vars := binding.new_eval_variables()
// 	res := comp.evaluate(vars)
// 	return res
