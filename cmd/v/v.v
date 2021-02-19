import lib.comp.token
import lib.comp.parser
import lib.comp.binding
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
	print_exprs()
}

fn print_exprs() {
	term.clear()
	mut show_tree := false
	table := binding.new_symbol_table()
	for {
		print(term.ok_message('expr:'))
		print('> ')
		line := os.get_line()
		if line == '' {
			break
		}
		if line == '#tree' {
			show_tree = !show_tree
			println(term.bright_blue(if show_tree { '  enabling tree' } else { '  disabling tree' }))
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

		mut comp := comp.new_compilation(syntax_tree, table)
		res := comp.evaluate()
		if res.result.len > 0 {
			for err in res.result {
				line_nr := syntax_tree.source.line_nr(err.pos.pos)
				prefix := line[0..err.pos.pos]
				error := line[err.pos.pos..err.pos.pos + err.pos.len]
				postfix := line[err.pos.pos + err.pos.len..]

				println(term.red(err.text))
				print('$line_nr|   ')
				print(prefix)
				print(term.red(error))
				println(postfix)
			}
		} else {
			println(term.yellow('    $res.val'))
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
