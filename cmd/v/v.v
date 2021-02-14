import lib.comp.token
import lib.comp.parser
import lib.comp
// import lib.comp.ast
import os
import term

fn main() {
	args := os.args[1..]
	if args.len > 0 {
		if '-tokeninzer' in args {
			tokenizer()
			exit(0)
		}
	}
	print_expressions()
}

fn print_expressions() {
	term.clear()
	mut show_tree := false
	for {
		print(term.ok_message('expr:'))
		print('> ')
		line := os.get_line()
		if line == '' {
			break
		}
		if line == '#tree' {
			show_tree = !show_tree
			println(term.bright_blue(if show_tree {'  enabling tree'}else{'  disabling tree'}))
			continue
		}
		if line == '#cls' {
			term.clear()
			continue
		}
		syntax_tree := parser.parse_syntax_tree(line)
		
		if show_tree {
			parser.pretty_print(syntax_tree.root, '', true)
		}

		if syntax_tree.log.all.len > 0 {
			for err in syntax_tree.log.all {
				println(term.fail_message(err.text))
			}
		} else {
			mut comp := comp.new_compilation(syntax_tree)
			res := comp.evaluate()
			if res.result.len > 0 {
				for err in res.result {
					println(term.fail_message(err.text))
				}
			} else {
				println(term.yellow('    $res.val'))
			}
		}
	}
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
