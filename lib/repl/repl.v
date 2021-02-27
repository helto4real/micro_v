module repl

import term.ui as tui
import term
import os
import strings
import lib.comp.binding
import lib.comp.parser
import lib.comp.types
import lib.comp.token
import lib.comp.lowering
import lib.comp.util
import lib.comp
import lib.comp.ast.walker
import lib.comp.binding.walker as bwalker
import lib.comp.ast

struct App {
mut:
	tree          []string
	btree         []string
	ltree         []string
	show_tree     bool
	show_btree    bool
	show_ltree    bool
	tui           &tui.Context = 0
	ed            &Buffer      = 0
	viewport      int
	footer_height int = 2
	t             int
	status        string
	error_msg     string
	has_val       bool
	val           types.LitVal = ' '
	// is multi line editing
	is_ml bool

	vars      &binding.EvalVariables = 0
	prev_comp &comp.Compilation      = 0
}

fn (a &App) view_height() int {
	return a.tui.window_height - a.footer_height - 1
}

fn (mut a App) colorize() {
	mut b := a.ed
	raw_text := b.raw()
	if raw_text.len == 0 {
		return
	}
	source := util.new_source_text(b.raw())
	mut tnz := token.new_tokenizer_from_source(source)
	tokens := tnz.scan_all()
	for tok in tokens {
		pos := tok.pos
		line_nr := source.line_nr(pos.pos)
		line := source.lines[line_nr - 1]
		match tok.kind {
			.eof {
				break
			}
			.name {
				start := pos.pos - line.start + 1
				a.tui.draw_text(start, line_nr, term.bright_blue('$tok.lit'))
			}
			.key_true, .key_false, .number {
				start := pos.pos - line.start + 1
				a.tui.draw_text(start, line_nr, term.rgb(200, 200, 200, '$tok.lit'))
			}
			else {
				kind_str := tok.kind.str()
				if kind_str.contains('key') {
					start := pos.pos - line.start + 1
					a.tui.draw_text(start, line_nr, term.magenta('$tok.lit'))
				}
			}
		}
	}
}

fn (mut a App) message() {
	mut b := a.ed

	if a.status == '' {
		a.tui.draw_text(2, b.lines.len + 1, term.yellow('$a.val'))
	} else if a.error_msg.len > 0 {
		a.tui.draw_text(2, b.lines.len + 1, a.error_msg)
	}

	if a.tree.len > 0 {
		for i, s in a.tree {
			a.tui.draw_text(0, i + 5, s)
		}
		// a.tree.clear()
	} else if a.btree.len > 0 {
		for i, bs in a.btree {
			a.tui.draw_text(0, i + 5, bs)
		}
		// a.btree.clear()
	}
}
fn (mut a App) footer() {
	w, h := a.tui.window_width, a.tui.window_height
	mut b := a.ed
	// flat := b.flat()
	// snip := if flat.len > 19 { flat[..20] } else { flat }
	a.tui.draw_text(0, h - 1, '─'.repeat(w))
	footer := ' Line ${b.cursor.pos_y + 1:4}/${b.lines.len:-4}, Column ${b.cursor.pos_x + 1:3}/${b.cur_line().len:-3} index: ${b.cursor_index():5} (ESC = quit, Ctrl+s = save)'
	if footer.len < w {
		a.tui.draw_text((w - footer.len) / 2, h, footer)
	} else if footer.len == w {
		a.tui.draw_text(0, h, footer)
	} else {
		a.tui.draw_text(0, h, footer[..w])
	}
	if a.status.len > 0 {
		a.tui.set_bg_color(
			r: 200
			g: 0
			b: 0
		)
		a.tui.set_color(
			r: 0
			g: 0
			b: 0
		)
		a.tui.draw_text((w + 4 - a.status.len) / 2, h - 1, ' $a.status ')
		a.tui.reset()
		// a.t -= 33
	}
}

fn (mut a App) visit_tree(node ast.Node, last_child bool, indent string) ?string {
	mut b := strings.new_builder(0)

	marker := if last_child { '└──' } else { '├──' }

	b.write_string(term.gray(indent))
	if indent.len > 0 {
		b.write_string(term.gray(marker))
	}
	new_ident := indent + if last_child { '   ' } else { '│  ' }
	node_str := node.node_str()

	if node_str[0] == `&` {
		// b.write_string(term.gray(node_str[5..]))
		b.writeln(term.gray(node_str[5..]))
	} else {
		b.write_string(term.gray('Token '))
		b.writeln(term.bright_cyan(node_str))
	}

	a.tree << b.str()
	// a.tree << '${node.node_str()} ($last_child)'
	return new_ident
}

fn (mut a App) visit_btree(node binding.BoundNode, last_child bool, indent string) ?string {
	mut b := strings.new_builder(0)

	marker := if last_child { '└──' } else { '├──' }

	b.write_string(term.gray(indent))
	if indent.len > 0 {
		b.write_string(term.gray(marker))
	}
	new_ident := indent + if last_child { '   ' } else { '│  ' }
	node_str := node.node_str()

	b.write_string(term.gray(node_str[9..]))
	match node {
		binding.BoundExpr {
			if node is binding.BoundLiteralExpr {
				b.writeln(term.bright_cyan(' $node.val'))
			} else if node is binding.BoundBinaryExpr {
				b.writeln(term.bright_cyan(' $node.op.kind'))
			} else if node is binding.BoundUnaryExpr {
				b.writeln(term.bright_cyan(' $node.op.kind'))
			} else {
				b.writeln('')
			}
		}
		binding.BoundStmt {
			if node is binding.BoundLabelStmt {
				b.writeln(term.bright_cyan(' $node.name'))
			} else if node is binding.BoundCondGotoStmt {
				b.writeln(term.bright_cyan(' $node.jump_if_true -> $node.label'))
			} else if node is binding.BoundGotoStmt {
				b.writeln(term.bright_cyan(' $node.label'))
			} else {
				b.writeln('')
			}
		}
	}

	a.btree << b.str()
	return new_ident
}

fn event(e &tui.Event, x voidptr) {
	mut app := &App(x)
	mut buffer := app.ed

	if e.typ == .key_down {
		match e.code {
			.enter {
				// if last line, lets evaluate
				if buffer.cursor.pos_y == buffer.lines.len - 1 {
					app.tui.draw_text(4, buffer.cursor.pos_y + 4, term.yellow('y: $buffer.cursor.pos_y len: $buffer.lines.len'))

					syntax_tree := parser.parse_syntax_tree(buffer.raw())
					if syntax_tree.log.all.len == 0 {
						mut comp := if app.prev_comp == 0 {
							comp.new_compilation(syntax_tree)
						} else {
							app.prev_comp.continue_with(syntax_tree)
						}
						res := comp.evaluate(app.vars)
						if res.result.len == 0 {
							app.prev_comp = comp
							app.has_val = true
							app.val = res.val
							app.status = ''
							app.error_msg = ''

							if app.show_tree {
								walker.walk_tree(app, syntax_tree.root)
							} else if app.show_btree {
								bwalker.walk_tree(app, comp.global_scope.stmt)
							} else if app.show_ltree {
								lowered_tree := lowering.lower(comp.global_scope.stmt)
								bwalker.walk_tree(app, binding.BoundStmt(lowered_tree))
							}
							// walker.inspect(syntax_tree.root)
							// fn (node ast.Node, data voidptr)
						} else {
							mut b := strings.new_builder(0)
							text := buffer.raw() // syntax_tree.source.str()
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

								b.writeln(term.red(err.text))
								b.writeln('')
								b.write_string('$line_nr| ')
								b.write_string(prefix.trim('\r\n'))
								b.write_string(term.red(error))
								b.writeln(postfix)
								b.writeln('')
							}

							app.has_val = false
							app.status = res.result[0].text
							app.t = 3
							app.error_msg = b.str()
							// os.write_file('errors.txt', '$res') or { }
						}
					} else {
						app.error_msg = ''
						app.has_val = false
						app.status = syntax_tree.log.all[0].text
						app.t = 1
						// os.write_file('errors.txt', '$syntax_tree.log') or { }
					}
				}
				buffer.put('\n')
			}
			.backspace {
				buffer.del(-1)
			}
			.delete {
				buffer.del(1)
			}
			.up {
				buffer.move_cursor(1, .up)
			}
			.down {
				buffer.move_cursor(1, .down)
			}
			.left {
				buffer.move_cursor(1, .left)
			}
			.right {
				buffer.move_cursor(1, .right)
			}
			48...57, 97...122 {
				if e.modifiers == .ctrl {
					if e.code == .s {
						// save current raw text
						os.write_file('output.txt', buffer.raw()) or { }
					} else if e.code == .t {
						// tree mode
						app.show_tree = !app.show_tree
						app.show_btree = false
						app.show_ltree = false
					} else if e.code == .b {
						// tree mode
						app.show_btree = !app.show_btree
						app.show_tree = false
						app.show_ltree = false
					} else if e.code == .l {
						// tree mode
						app.show_ltree = !app.show_btree
						app.show_tree = false
						app.show_btree = false
					}
				} else {
					buffer.put(e.ascii.ascii_str())
				}
			}
			.tab {
				buffer.put('  ')
			}
			else {
				buffer.put(e.utf8.bytes().bytestr())
			}
		}
	}

	if e.typ == .key_down && e.code == .escape {
		app.tui.clear()
		app.tui.flush()
		exit(0)
	}
}

fn frame(x voidptr) {
	mut a := &App(x)
	mut ed := a.ed
	a.tui.clear()
	scroll_limit := a.view_height()
	// scroll down
	if ed.cursor.pos_y > a.viewport + scroll_limit { // scroll down
		a.viewport = ed.cursor.pos_y - scroll_limit
	} else if ed.cursor.pos_y < a.viewport { // scroll up
		a.viewport = ed.cursor.pos_y
	}
	view := ed.view(a.viewport, scroll_limit + a.viewport)
	a.tui.draw_text(0, 0, term.rgb(120, 120, 120, view.raw))
	a.message()
	a.footer()
	a.colorize()
	a.tui.set_cursor_position(view.cursor.pos_x + 1, ed.cursor.pos_y + 1 - a.viewport)
	a.tui.flush()
}

// App callbacks
fn init(x voidptr) {
	mut a := &App(x)
	a.ed = &Buffer{}
	a.vars = binding.new_eval_variables()
	a.prev_comp = &comp.Compilation(0)

	a.tui.clear()
	a.tui.write(term.bright_blue('INIT\n\n'))
	a.tui.flush()
}

fn imax(x int, y int) int {
	return if x < y { y } else { x }
}

fn imin(x int, y int) int {
	return if x < y { x } else { y }
}

pub fn run() ? {
	mut app := &App{}
	app.tui = tui.init(
		user_data: app
		event_fn: event
		init_fn: init
		window_title: 'V term.ui event viewer'
		hide_cursor: false
		capture_events: true
		frame_rate: 60
		frame_fn: frame
		use_alternate_buffer: false
	)
	app.tui.run() ?
}