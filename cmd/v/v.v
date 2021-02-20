import lib.comp.token
import lib.comp.parser
import lib.comp
// import lib.comp.binding
import os
import term
import strings

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
	vars := comp.new_eval_variables()
	mut builder := strings.new_builder(30)
	mut prev_comp := &comp.Compilation(0)

	for {
		if builder.len == 0 {
			print(term.ok_message('»'))
		} else {
			print(' | ')
		}
		line := os.get_line()
		is_blank := line == ''

		if builder.len == 0 {
			if is_blank {
				builder = strings.new_builder(30)
				break
			} else if line == '#tree' {
				show_tree = !show_tree
				println(term.bright_blue(if show_tree {
					'  enabling tree'
				} else {
					'  disabling tree'
				}))
				continue
			} else if line == '#cls' {
				term.clear()
				continue
			}
		}
		builder.writeln(line)
		text := builder.last_n(builder.len)
		syntax_tree := parser.parse_syntax_tree(text)

		if !is_blank && syntax_tree.log.all.len > 0 {
			continue
		}
		if show_tree {
			parser.pretty_print(syntax_tree.root.expr, '', true)
		}

		mut comp := if prev_comp == 0 {
			comp.new_compilation(syntax_tree)
		} else {
			prev_comp.continue_with(syntax_tree)
		}
		
		res := comp.evaluate(vars)
		if res.result.len > 0 {
			for err in res.result {
				line_nr := syntax_tree.source.line_nr(err.pos.pos)
				prefix := text[0..err.pos.pos]
				mut err_end_pos := err.pos.pos + err.pos.len
				if err_end_pos > text.len {
					err_end_pos = text.len
				}
				error := text[err.pos.pos..err_end_pos]

				postfix := if err_end_pos + err.pos.len < text.len {
					text[err.pos.pos + err.pos.len..]
				} else {
					''
				}

				println(term.red(err.text))
				println('')
				print('$line_nr| ')
				print(prefix.trim('\r\n'))
				print(term.red(error))
				println(postfix)
				println('')
			}
		} else {
			println(term.yellow('   $res.val'))
			prev_comp = comp
		}
		builder.go_back_to(0)
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
