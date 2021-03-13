import term
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
		write_diagnostics(res.result, syntax_tree)
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
pub fn write_diagnostics(diagnostics []&source.Diagnostic, syntax_tree parser.SyntaxTree) {
	mut sorted_diagnosics := []&source.Diagnostic{cap: diagnostics.len}
	sorted_diagnosics << diagnostics
	sorted_diagnosics.sort(a.pos.pos < b.pos.pos)
	mut iw := repl.IdentWriter{}
	for err in sorted_diagnosics {
		src := syntax_tree.source.str()
		line_nr := syntax_tree.source.line_nr(err.pos.pos)
		line := syntax_tree.source.lines[line_nr-1]
		col := err.pos.pos - line.start
		// line_index := syntax_tree.source.line_index(err.pos.pos)
		prefix := src[0..err.pos.pos]
		mut err_end_pos := err.pos.pos + err.pos.len
		if err_end_pos > src.len {
			err_end_pos = src.len
		}
		error := src[err.pos.pos..err_end_pos]

		postfix := if err_end_pos + err.pos.len < src.len {
			src[err.pos.pos + err.pos.len..]
		} else {
			''
		}

		iw.writeln(term.red('($line_nr, $col) $err.text'))
		iw.writeln('')
		iw.write(prefix.trim('\r\n'))
		iw.write(term.red(error))
		iw.writeln(postfix)
		iw.writeln('')
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
