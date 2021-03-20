module binding

import lib.comp.io
import lib.comp.ast
import lib.comp.token
import lib.comp.symbols

pub fn write_node(writer io.TermTextWriter, node BoundNode) {
	match node {
		BoundExpr { write_expr(writer, node) }
		BoundStmt { write_stmt(writer, node) }
	}
}

fn write_expr(writer io.TermTextWriter, node BoundExpr) {
	match node {
		BoundAssignExpr {
			writer.write_identifier(node.var.name)
			writer.write_space()
			writer.write_punctuation('=')
			writer.write_space()
			write_expr(writer, node.expr)
		}
		BoundBinaryExpr {
			prec := ast.binary_operator_precedence(node.op.kind)
			write_nested_expr(writer, prec, node.left)
			writer.write_space()
			writer.write_punctuation(token.token_str[node.op.kind])
			writer.write_space()
			write_nested_expr(writer, prec, node.right)
		}
		BoundCallExpr {
			writer.write_identifier(node.func.name)
			writer.write_punctuation('(')
			for i, arg in node.params {
				if i != 0 {
					writer.write_punctuation(',')
					writer.write_space()
				}
				write_expr(writer, arg)
			}
			writer.write_punctuation(')')
		}
		BoundConvExpr {
			writer.write_identifier(node.typ.name)
			writer.write_punctuation('(')
			write_expr(writer, node.expr)
			writer.write_punctuation(')')
		}
		BoundErrorExpr {
			writer.write_keyword('?')
		}
		BoundIfExpr {
			writer.write_keyword('if')
			writer.write_space()
			write_expr(writer, node.cond_expr)
			writer.write_space()
			write_nested_stmt(writer, node.then_stmt)
			writer.write_keyword('else')
			writer.write_space()
			write_nested_stmt(writer, node.else_stmt)
		}
		BoundLiteralExpr {
			val := node.const_val.val
			match val {
				string {
					writer.write_string("'$val'")
				}
				int {
					writer.write_number(val.str())
				}
				bool {
					lit := if val { 'true' } else { 'false' }
					writer.write_number(lit)
				}
				symbols.None {
					writer.write_punctuation('<nil>')
				}
			}
		}
		BoundRangeExpr {
			write_expr(writer, node.from_exp)
			writer.write_punctuation('..')
			write_expr(writer, node.to_exp)
		}
		BoundUnaryExpr {
			prec := ast.unary_operator_precedence(node.op.kind)
			writer.write_punctuation(token.token_str[node.op.kind])
			write_nested_expr(writer, prec, node.operand)
		}
		BoundVariableExpr {
			writer.write_identifier(node.var.name)
		}
		BoundEmptyExpr {
			writer.write_identifier(node.str())
		}
	}
}

fn write_stmt(writer io.TermTextWriter, node BoundStmt) {
	match node {
		BoundBlockStmt {
			writer.write_punctuation('{')
			writer.writeln('')
			writer.indent_add(1)
			for stmt in node.bound_stmts {
				write_stmt(writer, stmt)
			}
			writer.indent_add(-1)
			writer.write_punctuation('}')
			writer.writeln('')
		}
		BoundCondGotoStmt {
			writer.write_keyword('goto')
			writer.write_space()
			writer.write_identifier(node.label)
			writer.write_space()
			cond_str := if node.jump_if_true { 'if' } else { 'unless' }
			writer.write_number(cond_str)
			writer.write_space()
			write_expr(writer, node.cond)
			writer.writeln('')
		}
		BoundExprStmt {
			write_expr(writer, node.bound_expr)
			writer.writeln('')
		}
		BoundForRangeStmt {
			writer.write_keyword('for')
			writer.write_space()
			writer.write_identifier(node.ident.name)
			writer.write_space()
			writer.write_keyword('in')
			writer.write_space()
			write_expr(writer, node.range_expr)
			writer.write_space()
			write_nested_stmt(writer, node.body_stmt)
		}
		BoundForStmt {
			writer.write_keyword('for')
			writer.write_space()
			if node.has_cond {
				write_expr(writer, node.cond_expr)
				writer.write_space()
			}
			write_nested_stmt(writer, node.body_stmt)
		}
		BoundGotoStmt {
			writer.write_keyword('goto')
			writer.write_space()
			writer.write_identifier(node.label)
			writer.writeln('')
		}
		BoundModuleStmt {
			writer.write_keyword('module')
			writer.write_space()
			writer.write_identifier(node.name)
			writer.writeln('')
		}
		BoundIfStmt {
			writer.write_keyword('if')
			writer.write_space()
			write_expr(writer, node.cond_expr)
			writer.write_space()
			write_nested_stmt(writer, node.block_stmt)
			if node.has_else {
				writer.write_keyword('else')
				writer.write_space()
				write_nested_stmt(writer, node.else_clause)
			}
		}
		BoundLabelStmt {
			unindent := writer.indent() > 0
			if unindent {
				writer.indent_add(-1)
			}
			writer.write_punctuation(node.name)
			writer.write_punctuation(':')
			writer.writeln('')

			if unindent {
				writer.indent_add(1)
			}
		}
		BoundVarDeclStmt {
			writer.write_identifier(node.var.name)
			writer.write_space()
			writer.write_punctuation(':=')
			writer.write_space()
			write_expr(writer, node.expr)
			writer.writeln('')
		}
		BoundBreakStmt {
			writer.write_keyword('break')
			writer.writeln('')
		}
		BoundContinueStmt {
			writer.write_comment('continue')
			writer.writeln('')
		}
		BoundCommentStmt {
			writer.write_comment(node.comment)
			writer.writeln('')
		}
		BoundReturnStmt {
			writer.write_keyword('return')
			if node.has_expr {
				writer.write_space()
				write_expr(writer, node.expr)
			}
			writer.writeln('')
		}
	}
}

fn write_nested_stmt(writer io.TermTextWriter, node BoundStmt) {
	needs_identation := !(node is BoundBlockStmt)
	if needs_identation {
		writer.indent_add(1)
	}
	write_stmt(writer, node)
	if needs_identation {
		writer.indent_add(-1)
	}
}

fn write_nested_expr(writer io.TermTextWriter, parent_prec int, node BoundExpr) {
	if node is BoundUnaryExpr {
		write_nested_expr_ex(writer, parent_prec, ast.unary_operator_precedence(node.op.kind),
			node)
	} else if node is BoundBinaryExpr {
		write_nested_expr_ex(writer, parent_prec, ast.binary_operator_precedence(node.op.kind),
			node)
	} else {
		write_expr(writer, node)
	}
}

fn write_nested_expr_ex(writer io.TermTextWriter, parent_prec int, current_prec int, node BoundExpr) {
	needs_paranthesis := parent_prec >= current_prec

	if needs_paranthesis {
		writer.write_punctuation('(')
	}
	write_expr(writer, node)
	if needs_paranthesis {
		writer.write_punctuation(')')
	}
}
