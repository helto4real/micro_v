module walker
import strings
import term
import lib.comp.binding
import lib.comp.parser
import lib.comp.lowering

pub struct BoundNodePrinter {
mut:
	tree []string
}
pub fn node_str(node binding.BoundNode) string {
	p := BoundNodePrinter{}
	walker.walk_tree(p, node)
	mut b := strings.new_builder(0)
	for s in p.tree {b.write_string(s)}
	return b.str()
}

pub fn print_block(block binding.BoundBlockStmt, shallow bool) string {
	mut b := strings.new_builder(0)
	for stmt in block.child_nodes {
		s := node_str(stmt)
		b.write_string(s)
	}
	return b.str()
}
pub fn print_expression(expr string, shallow bool) string {
	// vars := binding.new_eval_variables()
	syntax_tree := parser.parse_syntax_tree(expr)
	if syntax_tree.log.all.len > 0 {
		return 'syntax error'
	}
	scope := binding.bind_global_scope(&binding.BoundGlobalScope(0), syntax_tree.root)
	lower := if !shallow { lowering.lower(scope.stmt)} else {lowering.lower_shallow(scope.stmt)}
	// mut comp := comp.new_compilation(syntax_tree)
	// res := comp.evaluate(vars)
	if scope.log.all.len > 0 {
		return 'error binding expression'
	}
	mut b := strings.new_builder(0)
	for stmt in lower.child_nodes {
		s := node_str(stmt)
		b.write_string(s)
	}
	return b.str()
}
fn (mut p BoundNodePrinter) visit_btree(node binding.BoundNode, last_child bool, indent string) ?string {
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
			} else if node is binding.BoundVariableExpr {
				b.writeln(term.bright_cyan(' $node.var.name() ($node.var.typ().name)'))
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
			} else if node is binding.BoundForStmt {
				b.writeln(term.bright_cyan(' $node.child_nodes.len'))
			} else if node is binding.BoundVarDeclStmt {
				b.writeln(term.bright_cyan(' $node.var.name() ($node.var.typ().name'))
			} else {
				b.writeln('')
			}
		}
	}

	p.tree << b.str()
	return new_ident
}