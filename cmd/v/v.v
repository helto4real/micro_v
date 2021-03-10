import term
import strings
import lib.comp.token
import lib.repl
import os
import lib.comp.types
import lib.comp.binding
import lib.comp.parser
import lib.comp

fn main() {
	args := os.args[1..]
	if args.len > 0 {
		if '-tokeninzer' in args {
			tokenizer()
			exit(0)
		} else {
			// it is a file 
			src := os.read_file(args[0]) ?
			// println(src)
			syntax_tree := parser.parse_syntax_tree(src)
			if syntax_tree.log.all.len > 0 {
				for log in syntax_tree.log.all {
					eprintln(log)
				}
				exit(0)
			}
			mut comp := comp.new_compilation(syntax_tree)
			vars := binding.new_eval_variables()
			res := comp.evaluate(vars)
			if res.result.len == 0 {
				if res.val !is types.None {
					println(term.yellow(res.val.str()))
				}
				println(term.cyan('OK'))
				exit(0)
			}
			mut b := strings.new_builder(0)
			for err in res.result {
				line_nr := syntax_tree.source.line_nr(err.pos.pos)
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

				b.writeln(term.red(err.text))
				b.writeln('')
				b.write_string('$line_nr| ')
				b.write_string(prefix.trim('\r\n'))
				b.write_string(term.red(error))
				b.writeln(postfix)
				b.writeln('')
			}
			println(b.str())
			exit(0)
		}
	}

	repl.run() ?
}

fn tokenizer() {
	for {
		print('tokens> ')
		line := os.get_line()
		if line == '' {
			break
		}
		mut tnz := token.new_tokenizer_from_string(line)
		mut tokens := tnz.scan_all()
		for _, token in tokens {
			println(token)
			if token.kind == .eof {
				break
			}
		}
	}
}

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
