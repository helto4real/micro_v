module walker

import strings
import term
import lib.comp.ast

struct NodePrinter {
mut:
	tree []string
}

pub fn print_expression(node ast.Node) string {
	p := NodePrinter{}
	walk_tree(p, node)
	mut b := strings.new_builder(0)
	for s in p.tree {
		b.write_string(s)
	}
	return b.str()
}

fn (mut p NodePrinter) visit_tree(node ast.Node, last_child bool, indent string) ?string {
	mut b := strings.new_builder(0)

	marker := if last_child { '└──' } else { '├──' }

	b.write_string(term.gray(indent))
	if indent.len > 0 {
		b.write_string(term.gray(marker))
	}
	new_ident := indent + if last_child { '   ' } else { '│  ' }
	mut node_str := node.node_str()
	if node_str[0] == `&` {
		node_str = node_str[5..]
	}

	b.writeln(term.gray(node_str))
	match node {
		ast.Expr {
			if node is ast.LiteralExpr {
				b.writeln(term.bright_cyan(' $node.val'))
			} else if node is ast.BinaryExpr {
				b.writeln(term.bright_cyan(' $node.op_tok.kind'))
			} else if node is ast.NameExpr {
				b.writeln(term.bright_cyan(' ${node.name}'))
			} else if node is ast.UnaryExpr {
				b.writeln(term.bright_cyan(' $node.op_tok.kind'))
			} else {
				b.writeln('')
			}
		}
		ast.Stmt {
			if node is ast.VarDeclStmt {
				b.writeln(term.bright_cyan(' $node.ident.name_tok.lit'))
			} else {
				b.writeln('')
			}
		}
		else {}
	}

	p.tree << b.str()
	return new_ident
}
