import lib.comp.token
import lib.repl
import os
// import lib.comp.binding.walker
// import lib.comp.binding
// import lib.comp.parser
// import lib.comp
// import lib.comp.util
fn main() {

	args := os.args[1..]
	if args.len > 0 {
		if '-tokeninzer' in args {
			tokenizer()
			exit(0)
		}
	}

	repl.run() ?


	// syntax_tree := parser.parse_syntax_tree(
	// 	'
	// 	    {
	// 			mut a := 0
	// 			for b in 0..10 {
	// 				a = a + b
	// 			}
	// 			a
	// 		}
	// 		')
	// // syntax_tree := parser.parse_syntax_tree(
	// // 	'
	// // 	    {
	// // 			mut a := 0
	// // 			mut b := 0
	// // 			for a < 5{
	// // 				b = b - 1
	// // 				a = a + 1
					
	// // 			}
	// // 			b
	// // 		}
	// // 		')
	// if syntax_tree.log.all.len > 0 {
	// 	println('syntax error')
	// 	return
	// }
	// vars :=  binding.new_eval_variables()
	// mut comp := comp.new_compilation(syntax_tree)
	// res := comp.evaluate(vars)
	// println('RES: $res')
}

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
// }

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
