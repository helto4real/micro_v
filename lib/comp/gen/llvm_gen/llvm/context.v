module llvm
import lib.comp.binding

pub struct Context {
	mod Module
pub:
	value_refs map[string]C.LLVMValueRef
}

pub fn new_context(mod Module) Context {
	return Context{mod:mod}
}

fn (c Context) emit_node(node binding.BoundNode) {
	match node {
		binding.BoundExpr {
			if node is binding.BoundLiteralExpr {
				emit_bound_litera_expr(node)
			} else if node is binding.BoundBinaryExpr {
				b.writeln(term.bright_cyan(' $node.op.kind'))
			} else if node is binding.BoundVariableExpr {
				b.writeln(term.bright_cyan(' $node.var.name() ($node.var.typ.name)'))
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
				b.writeln(term.bright_cyan(' $node.var.name() ($node.var.typ.name'))
			} else {
				b.writeln('')
			}
		}
	}
}

fn (c Context) emit_bound_litera_expr(lit binding.BoundLiteralExpr) {
	value_refs
}