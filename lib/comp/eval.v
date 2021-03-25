module comp

import os
import lib.comp.binding
import lib.comp.symbols

pub struct Evaluator {
	// root     binding.BoundBlockStmt
	fn_stmts  map[string]binding.BoundBlockStmt
	program   &binding.BoundProgram
mut:
	glob_vars &binding.EvalVariables
	locals    binding.EvalVarsStack
	last_val  symbols.LitVal = symbols.None{}
	print_ref voidptr
	print_fn  PrintFunc
	is_func   bool
}

pub fn new_evaluator(program &binding.BoundProgram, glob_vars &binding.EvalVariables) Evaluator {
	// lowered_stmt := binding.lower(program.stmt)
	mut lowered_fn_stmts := map[string]binding.BoundBlockStmt{}

	for id, func_body in program.func_bodies {
		lowered_body := binding.lower(func_body)
		lowered_fn_stmts[id] = lowered_body
	}
	
	mut current_program := program 
	for current_program != 0 {
		for id, func_body in current_program.func_bodies {
			lowered_body := binding.lower(func_body)
			lowered_fn_stmts[id] = lowered_body
		}
		current_program = current_program.previous
	}

	// If you want to display the control flow graph, uncomment following lines

	// mut cfg_stmt := binding.BoundBlockStmt{}
	// if program.stmt.bound_stmts.len == 0 && program.func_bodies.len > 0 {
	// 	cfg_stmt = binding.lower(program.func_bodies[program.func_bodies.keys().last()])
	// } else {
	// 	cfg_stmt = lowered_stmt
	// }
	// cfg := binding.create_control_flow_graph(cfg_stmt)
	// exe_path := os.join_path(os.dir(os.executable()), 'text.dot')
	// mut f := os.open_file(exe_path,'w+', 0o666) or {panic(err)}
	// defer {f.close()}
	// cfg.write_to(f) or {panic('unexpected error $err writing to file')}

	mut eval := Evaluator{
		program: program
		fn_stmts: lowered_fn_stmts
		glob_vars: glob_vars
		print_fn: print_fn
	}

	// Add root local variable scope
	eval.locals.push(binding.new_eval_variables())
	return eval
}

pub fn (mut e Evaluator) register_print_callback(print_fn PrintFunc, ref voidptr) {
	e.print_ref = ref
	e.print_fn = print_fn
}

pub fn (mut e Evaluator) evaluate() ?symbols.LitVal {
	e.is_func = false
	func := if e.program.main_func != symbols.undefined_fn {
		e.program.main_func
	} else {e.program.script_func}
	if func == symbols.undefined_fn {return symbols.None{}}
	body := e.fn_stmts[func.id]
	return e.evaluate_stmt(body)
}

pub fn (mut e Evaluator) evaluate_stmt(block binding.BoundBlockStmt) ?symbols.LitVal {
	e.last_val = symbols.None{}

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
							if cond {
								index = label_to_index[stmt.true_label]
							} else {
								index = label_to_index[stmt.false_label]
							}
						} else {
							panic('bound goto could never have other than bool conditions')
						}
					}
					binding.BoundLabelStmt {
						index++
					}
					binding.BoundReturnStmt {
						if stmt.has_expr {
							e.last_val = e.eval_expr(stmt.expr) or {
								'unexpected error evaluate expression'
							}
							return e.last_val
						} else {
							return symbols.None{}
						}
					}
					binding.BoundCommentStmt {
						// NOOP
						index++
					}
					binding.BoundModuleStmt {
						// NOOP
						index++
					}
					else {
						panic('unexpected stmt typ: $stmt.node_str()')
					} // will never happen
				}
			}
			else {
				panic('unexpected stmt typ: $stmt.node_str()')
			} // will never happen
		}
	}
	return e.last_val
}

fn (mut e Evaluator) eval_bound_var_decl_stmt(node binding.BoundVarDeclStmt) {
	val := e.eval_expr(node.expr) or { panic('unexpected compiler error') }

	e.assign_var(node.var, val)
}

fn (mut e Evaluator) eval_bound_expr_stmt(stmt binding.BoundExprStmt) {
	e.last_val = e.eval_expr(stmt.bound_expr) or {
		panic('unexpected error evaluate expresseion $stmt.bound_expr')
	}
}

fn (mut e Evaluator) eval_expr(node binding.BoundExpr) ?symbols.LitVal {
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

fn (mut e Evaluator) eval_bound_if_expr(node binding.BoundIfExpr) ?symbols.LitVal {
	cond_expr := e.eval_expr(node.cond_expr) ?
	cond := cond_expr as bool
	if cond {
		return e.evaluate_stmt((node.then_stmt as binding.BoundBlockStmt))
	} else {
		return e.evaluate_stmt((node.else_stmt as binding.BoundBlockStmt))
	}
}

fn (mut e Evaluator) eval_bound_conv_expr(node binding.BoundConvExpr) ?symbols.LitVal {
	val := e.eval_expr(node.expr) or { panic('unexpected error evaluate expression') }
	if node.typ is symbols.BuiltInTypeSymbol {
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
	}
	panic('unexpected allowed conversion')
}

fn (mut e Evaluator) eval_bound_call_expr(node binding.BoundCallExpr) ?symbols.LitVal {
	if node.func == symbols.input_symbol {
		return os.get_line()
	} else if node.func == symbols.print_symbol {
		msg := e.eval_expr(node.params[0]) or { panic('unexpected error eval expression') }
		e.print_fn(msg.str(), false, voidptr(e.print_ref))
	} else if node.func == symbols.println_symbol {
		msg := e.eval_expr(node.params[0]) or { panic('unexpected error eval expression') }
		e.print_fn(msg.str(), true, voidptr(e.print_ref))
	} else {
		// add a local variable scope
		mut locals := binding.new_eval_variables()
		for i, param in node.params {
			param_val := e.eval_expr(param) or { panic('expecting value') }
			param_fn := node.func.params[i]
			locals.assign_variable_value(param_fn, param_val)
		}
		e.locals.push(locals)

		// evaluate the function body
		stmt := e.fn_stmts[node.func.id]
		res := e.evaluate_stmt(stmt) ?

		// remove the local function body scope
		e.locals.pop() or {}
		return res
	}
	return e.last_val
}

fn (mut e Evaluator) eval_bound_range_expr(node binding.BoundRangeExpr) ?symbols.LitVal {
	from_val := e.eval_expr(node.from_exp) ?
	to_val := e.eval_expr(node.to_exp) ?
	return '${from_val as int}..${to_val as int}'
}

fn (mut e Evaluator) eval_bound_literal_expr(root binding.BoundLiteralExpr) ?symbols.LitVal {
	return root.const_val.val
}

fn (mut e Evaluator) eval_bound_variable_expr(bound_var binding.BoundVariableExpr) ?symbols.LitVal {
	var_symbol := bound_var.var
	if var_symbol is symbols.GlobalVariableSymbol {
		return e.glob_vars.lookup(bound_var.var) or { panic('expected variable existing') }
	} else {
		mut local_symb := e.locals.peek() or { panic('unexpected empty stack') }
		return local_symb.lookup(bound_var.var) or {
			panic('expected local variable $bound_var.var to exist in local symbol table: $local_symb')
		}
	}
}

fn (mut e Evaluator) assign_var(var symbols.VariableSymbol, val symbols.LitVal) {
	if var is symbols.GlobalVariableSymbol {
		e.glob_vars.assign_variable_value(var, val)
	} else {
		mut locals := e.locals.peek() or { panic('unexpected local variable scope not exists') }
		locals.assign_variable_value(var, val)
	}
}

fn (mut e Evaluator) eval_bound_assign_expr(node binding.BoundAssignExpr) ?symbols.LitVal {
	val := e.eval_expr(node.expr) ?
	e.assign_var(node.var, val)
	return val
}

fn (mut e Evaluator) eval_bound_unary_expr(node binding.BoundUnaryExpr) ?symbols.LitVal {
	operand := e.eval_expr(node.operand) ?
	match node.op.op_kind {
		.identity { return operand as int }
		.negation { return -(operand as int) }
		.logic_negation { return !(operand as bool) }
		.ones_compl { return ~(operand as int) }
		else { panic('unexpected unary token $node.op.op_kind') }
	}
}

fn (mut e Evaluator) eval_bound_binary_expr(node binding.BoundBinaryExpr) ?symbols.LitVal {
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
