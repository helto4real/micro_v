module golang

import lib.comp.io
import lib.comp.types
import lib.comp.ast
import lib.comp.token
import lib.comp.binding

pub fn write_node(writer io.CodeWriter, node binding.BoundNode) {
	match node {
		binding.BoundExpr { write_expr(writer, node) }
		binding.BoundStmt { write_stmt(writer, node) }
	}
}

fn write_expr(writer io.CodeWriter, node binding.BoundExpr) {
	match node {
		binding.BoundAssignExpr {
			writer.write(node.var.name)
			writer.write_space()
			writer.write('=')
			writer.write_space()
			write_expr(writer, node.expr)
		}
		binding.BoundBinaryExpr {
			prec := ast.binary_operator_precedence(node.op.kind)
			write_nested_expr(writer, prec, node.left)
			writer.write_space()
			writer.write(token.token_str[node.op.kind])
			writer.write_space()
			write_nested_expr(writer, prec, node.right)
		}
		binding.BoundCallExpr {
			writer.write(node.func.name)
			writer.write('(')
			for i, arg in node.params {
				if i != 0 {
					writer.write(',')
					writer.write_space()
				}
				write_expr(writer, arg)
			}
			writer.write(')')
		}
		binding.BoundConvExpr {
			typ := node.typ
			match typ.name {
				'string' {
					match node.expr.typ.name {
						'int' {
							writer.write('i_to_s')
						}
						else {}
					}
				} 
				else {}
			}
			writer.write('(')
			write_expr(writer, node.expr)
			writer.write(')')
		}
		binding.BoundErrorExpr {
			writer.write('?')
		}
		binding.BoundIfExpr {
			writer.write('if')
			writer.write_space()
			write_expr(writer, node.cond_expr)
			writer.write_space()
			write_nested_stmt(writer, node.then_stmt)
			writer.write('else')
			writer.write_space()
			write_nested_stmt(writer, node.else_stmt)
		}
		binding.BoundLiteralExpr {
			match node.val {
				string {
					writer.write('"$node.val"')
				}
				int {
					writer.write(node.val.str())
				}
				bool {
					lit := if node.val { 'true' } else { 'false' }
					writer.write(lit)
				}
				types.None {
					writer.write('<nil>')
				}
			}
		}
		binding.BoundRangeExpr {
			write_expr(writer, node.from_exp)
			writer.write('..')
			write_expr(writer, node.to_exp)
		}
		binding.BoundUnaryExpr {
			prec := ast.unary_operator_precedence(node.op.kind)
			writer.write(token.token_str[node.op.kind])
			write_nested_expr(writer, prec, node.operand)
		}
		binding.BoundVariableExpr {
			writer.write(node.var.name)
		}
		binding.BoundEmptyExpr {
			writer.write(node.str())
		}
	}
}

fn write_stmt(writer io.CodeWriter, node binding.BoundStmt) {
	match node {
		binding.BoundBlockStmt {
			writer.write('{')
			writer.writeln('')
			writer.indent_add(1)
			for stmt in node.bound_stmts {
				write_stmt(writer, stmt)
			}
			writer.indent_add(-1)
			writer.write('}')
			writer.writeln('')
		}
		binding.BoundCondGotoStmt {
			writer.write('goto')
			writer.write_space()
			writer.write(node.label)
			writer.write_space()
			cond_str := if node.jump_if_true { 'if' } else { 'unless' }
			writer.write(cond_str)
			writer.write_space()
			write_expr(writer, node.cond)
			writer.writeln('')
		}
		binding.BoundExprStmt {
			write_expr(writer, node.bound_expr)
			writer.writeln('')
		}
		binding.BoundForRangeStmt {
			lowered_for_range := lower_for_range(node)
			for stmt in lowered_for_range {
				write_stmt(writer, stmt)
			}
		}
		binding.BoundForStmt {
			writer.write('for')
			writer.write_space()
			if node.has_cond {
				write_expr(writer, node.cond_expr)
				writer.write_space()
			}
			write_nested_stmt(writer, node.body_stmt)
		}
		binding.BoundGotoStmt {
			writer.write('goto')
			writer.write_space()
			writer.write(node.label)
			writer.writeln('')
		}
		binding.BoundModuleStmt {
			writer.write('module')
			writer.write_space()
			writer.write(node.name)
			writer.writeln('')
		}
		binding.BoundIfStmt {
			writer.write('if')
			writer.write_space()
			write_expr(writer, node.cond_expr)
			writer.write_space()
			write_nested_stmt(writer, node.block_stmt)
			if node.has_else {
				writer.write('else')
				writer.write_space()
				write_nested_stmt(writer, node.else_clause)
			}
		}
		binding.BoundLabelStmt {
			unindent := writer.indent() > 0
			if unindent {
				writer.indent_add(-1)
			}
			writer.write(node.name)
			writer.write(':')
			writer.writeln('')

			if unindent {
				writer.indent_add(1)
			}
		}
		binding.BoundVarDeclStmt {
			writer.write(node.var.name)
			writer.write_space()
			writer.write(':=')
			writer.write_space()
			write_expr(writer, node.expr)
			writer.writeln('')
		}
		binding.BoundBreakStmt {
			writer.write('break')
			writer.writeln('')
		}
		binding.BoundContinueStmt {
			writer.write('continue')
			writer.writeln('')
		}
		binding.BoundCommentStmt {
			writer.write(node.comment)
			writer.writeln('')
		}
		binding.BoundReturnStmt {
			writer.write('return')
			if node.has_expr {
				writer.write_space()
				write_expr(writer, node.expr)
			}
			writer.writeln('')
		}
	}
}

fn write_nested_stmt(writer io.CodeWriter, node binding.BoundStmt) {
	needs_identation := !(node is binding.BoundBlockStmt)
	if needs_identation {
		writer.indent_add(1)
	}
	write_stmt(writer, node)
	if needs_identation {
		writer.indent_add(-1)
	}
}

fn write_nested_expr(writer io.CodeWriter, parent_prec int, node binding.BoundExpr) {
	if node is binding.BoundUnaryExpr {
		write_nested_expr_ex(writer, parent_prec, ast.unary_operator_precedence(node.op.kind),
			node)
	} else if node is binding.BoundBinaryExpr {
		write_nested_expr_ex(writer, parent_prec, ast.binary_operator_precedence(node.op.kind),
			node)
	} else {
		write_expr(writer, node)
	}
}

fn write_nested_expr_ex(writer io.CodeWriter, parent_prec int, current_prec int, node binding.BoundExpr) {
	needs_paranthesis := parent_prec >= current_prec

	if needs_paranthesis {
		writer.write('(')
	}
	write_expr(writer, node)
	if needs_paranthesis {
		writer.write(')')
	}
}