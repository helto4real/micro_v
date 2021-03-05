module comp

import os
import lib.comp.binding
import lib.comp.types
import lib.comp.symbols

pub fn print_fn(text string, nl bool, ref voidptr) {
	if nl {
		println(text)
	} else {
		print(text)
	}
}

pub struct Evaluator {
	root binding.BoundBlockStmt
mut:
	glob_vars &binding.EvalVariables
	locals	  binding.EvalVarsStack
	last_val  types.LitVal = int(0)
	print_ref voidptr
	print_fn  PrintFunc
}

pub fn new_evaluator(root binding.BoundBlockStmt, glob_vars &binding.EvalVariables) Evaluator {
	return Evaluator{
		root: root
		glob_vars: glob_vars
		print_fn: print_fn
	}
}

pub fn (mut e Evaluator) register_print_callback(print_fn PrintFunc, ref voidptr) {
	e.print_ref = ref
	e.print_fn = print_fn
}

pub fn (mut e Evaluator) evaluate() ?types.LitVal {
	return e.evaluate_stmt(e.root)
}
pub fn (mut e Evaluator) evaluate_stmt(block binding.BoundBlockStmt) ?types.LitVal {
	e.last_val = types.None{}

	mut label_to_index := map[string]int{}
	for i, s in block.child_nodes {
		if s is binding.BoundStmt {
			if s is binding.BoundLabelStmt {
				label_to_index[s.name] = i + 1
			}
		}
	}
	mut index := 0

	for index < block.child_nodes.len {
		stmt := block.child_nodes[index]
		match stmt {
			binding.BoundStmt {
				match stmt {
					binding.BoundVarDeclStmt {
						e.eval_bound_var_decl_stmt(stmt)
						index++
					}
					binding.BoundExprStmt {
						e.eval_bound_expr_stmt(stmt)
						index++
					}
					binding.BoundGotoStmt {
						index = label_to_index[stmt.label]
					}
					binding.BoundCondGotoStmt {
						cond := e.eval_expr(stmt.cond) ?
						if cond is bool {
							if cond == stmt.jump_if_true {
								index = label_to_index[stmt.label]
							} else {
								index++
							}
						} else {
							panic('bound goto could never have other than bool conditions')
						}
					}
					binding.BoundLabelStmt {
						index++
					}
					else {
						panic('unexpected stmt typ: $stmt.node_str()')
					} // Will never happen
				}
			}
			else {
				panic('unexpected stmt typ: $stmt.node_str()')
			} // Will never happen
		}
	}
	return e.last_val
}

fn (mut e Evaluator) eval_bound_var_decl_stmt(node binding.BoundVarDeclStmt) {
	val := e.eval_expr(node.expr) or { panic('unexpected compiler error') }
	e.glob_vars.assign_variable_value(node.var, val)
	e.last_val = val
}

fn (mut e Evaluator) eval_bound_expr_stmt(stmt binding.BoundExprStmt) {
	e.last_val = e.eval_expr(stmt.bound_expr) or {
		panic('unexpected error evaluate expresseion $stmt.bound_expr')
	}
}

fn (mut e Evaluator) eval_expr(node binding.BoundExpr) ?types.LitVal {
	match node {
		binding.BoundLiteralExpr {
			return e.eval_bound_literal_expr(node)
		}
		binding.BoundUnaryExpr {
			return e.eval_bound_unary_expr(node)
		}
		binding.BoundBinaryExpr {
			return e.eval_bound_binary_expr(node)
		}
		binding.BoundVariableExpr {
			return e.eval_bound_variable_expr(node)
		}
		binding.BoundAssignExpr {
			return e.eval_bound_assign_expr(node)
		}
		binding.BoundCallExpr {
			return e.eval_bound_call_expr(node)
		}
		binding.BoundIfExpr {
			return e.eval_bound_if_expr(node)
		}
		binding.BoundRangeExpr {
			return e.eval_bound_range_expr(node)
		}
		binding.BoundConvExpr {
			return e.eval_bound_conv_expr(node)
		}
		else {
			panic('unexpected eval expr $node')
		}
	}
}

fn (mut e Evaluator) eval_bound_if_expr(node binding.BoundIfExpr) ?types.LitVal {
	cond_expr := e.eval_expr(node.cond_expr) ?
	cond := cond_expr as bool
	if cond {
		return e.evaluate_stmt((node.then_stmt as binding.BoundBlockStmt))
	} else {
		return e.evaluate_stmt((node.else_stmt as binding.BoundBlockStmt))
	}
}

fn (mut e Evaluator) eval_bound_conv_expr(node binding.BoundConvExpr) ?types.LitVal {
	val := e.eval_expr(node.expr) or { panic('unexpected error evaluate expression') }
	if node.typ == symbols.string_symbol {
		if val is int {
			return val.str()
		} else if val is bool {
			return val.str()
		}
	} else if node.typ == symbols.int_symbol {
		if val is string {
			return val.int()
		} else if val is bool {
			return if val { 1 } else { 0 }
		}
	} else if node.typ == symbols.bool_symbol {
		if val is string {
			return val == 'true'
		} else if val is int {
			return val != 0
		}
	}
	panic('unexpected allowed conversion')
}

fn (mut e Evaluator) eval_bound_call_expr(node binding.BoundCallExpr) ?types.LitVal {
	if node.func == symbols.input_symbol {
		return os.get_line()
	} else if node.func == symbols.print_symbol {
		msg := e.eval_expr(node.params[0]) or { panic('unexpected error eval expression') }
		e.print_fn(msg.str(), false, voidptr(e.print_ref))
	} else if node.func == symbols.println_symbol {
		msg := e.eval_expr(node.params[0]) or { panic('unexpected error eval expression') }
		e.print_fn(msg.str(), true, voidptr(e.print_ref))
	} else {
		// mut locals := binding.new_eval_variables()
		// for i, param in node.params {
		// 	param_val := e.eval_expr(param) or {panic('expecting value')}
		// 	param_fn := node.func.params[i]
		// 	locals.assign_variable_value(param_fn., param_val)
		// }
	}
	return e.last_val
}

fn (mut e Evaluator) eval_bound_range_expr(node binding.BoundRangeExpr) ?types.LitVal {
	from_val := e.eval_expr(node.from_exp) ?
	to_val := e.eval_expr(node.to_exp) ?
	return '${from_val as int}..${to_val as int}'
}

fn (mut e Evaluator) eval_bound_literal_expr(root binding.BoundLiteralExpr) ?types.LitVal {
	return root.val
}

fn (mut e Evaluator) eval_bound_variable_expr(root binding.BoundVariableExpr) ?types.LitVal {
	
	if !e.locals.is_empty() {
		mut local_symb := e.locals.peek() or {panic('unexpected empty stack')}
		local_var := local_symb.lookup(root.var) or {panic('expected local variable existing')}
		return local_var
	}
	var := e.glob_vars.lookup(root.var) or { panic('expected variable existing') }
	return var
}

fn (mut e Evaluator) eval_bound_assign_expr(node binding.BoundAssignExpr) ?types.LitVal {
	
	// Todo: store locals in stackframe not globals
	val := e.eval_expr(node.expr) ?
	e.glob_vars.assign_variable_value(node.var, val)
	return val
}

fn (mut e Evaluator) eval_bound_unary_expr(node binding.BoundUnaryExpr) ?types.LitVal {
	operand := e.eval_expr(node.operand) ?
	match node.op.op_kind {
		.identity { return operand as int }
		.negation { return -(operand as int) }
		.logic_negation { return !(operand as bool) }
		.ones_compl { return ~(operand as int) }
		else { panic('unexpected unary token $node.op.op_kind') }
	}
}

fn (mut e Evaluator) eval_bound_binary_expr(node binding.BoundBinaryExpr) ?types.LitVal {
	left := e.eval_expr(node.left) ?
	right := e.eval_expr(node.right) ?
	// compiler bug does exl_mark work with normal cast
	match node.op.op_kind {
		.addition { return (left as int) + (right as int) }
		.subraction { return (left as int) - (right as int) }
		.multiplication { return (left as int) * (right as int) }
		.divition { return (left as int) / (right as int) }
		.logic_and { return (left as bool) && (right as bool) }
		.logic_or { return (left as bool) || (right as bool) }
		.bitwise_and { return (left as int) & (right as int) }
		.bitwise_or { return (left as int) | (right as int) }
		.bitwise_xor { return (left as int) ^ (right as int) }
		.equals { return left.eq(right) }
		.not_equals { return !left.eq(right) }
		.greater { return left.gt(right) }
		.less { return left.lt(right) }
		.less_or_equals { return left.le(right) }
		.greater_or_equals { return left.ge(right) }
		.str_concat { return (left as string) + (right as string) }
		else { panic('operator <$node.op.op_kind> exl_mark expected') }
	}
}
