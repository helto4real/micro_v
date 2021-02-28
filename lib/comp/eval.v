module comp
// import strings
import lib.comp.binding
import lib.comp.types


pub struct Evaluator {
	root binding.BoundStmt
mut:
	vars     &binding.EvalVariables
	last_val types.LitVal = int(0)
}

pub fn new_evaluator(root binding.BoundStmt, vars &binding.EvalVariables) Evaluator {
	return Evaluator{
		root: root
		vars: vars
	}
}

pub fn (mut e Evaluator) evaluate() ?types.LitVal {

	mut label_to_index := map[string]int
	for i, s in e.root.child_nodes() {
		if s is binding.BoundStmt {
			if s is binding.BoundLabelStmt {
				label_to_index[s.name] = i + 1
			}
		}
    }
	mut index := 0
	for index < e.root.child_nodes().len {
		stmt := e.root.child_nodes()[index]
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
								index ++
							}
						} else {
							panic('bound goto could never have other than bool conditions')
						}
					}
					binding.BoundLabelStmt {
						index++
					}
					else {panic('unexpected stmt typ: ${stmt.node_str()}')} // Will never happen
				}
			}
			else {panic('unexpected stmt typ: ${stmt.node_str()}')} // Will never happen
		}
	}
	return e.last_val
}

fn (mut e Evaluator) eval_bound_var_decl_stmt(node binding.BoundVarDeclStmt) {
	val := e.eval_expr(node.expr) or { panic('unexpected compiler error') }
	e.vars.assign_variable_value(node.var, val)
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
		// binding.BoundIfExpr {
		// 	return e.eval_bound_if_expr(node)
		// }
		binding.BoundRangeExpr {
			return e.eval_bound_range_expr(node)
		}
		else {panic('unexpected eval expr ${node}')}
	}
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
	var := e.vars.lookup(root.var) or { return none }
	return var
}

fn (mut e Evaluator) eval_bound_assign_expr(node binding.BoundAssignExpr) ?types.LitVal {
	val := e.eval_expr(node.expr) ?
	e.vars.assign_variable_value(node.var, val)
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
		.str_concat {return (left as string) + (right as string) }
		else { panic('operator <$node.op.op_kind> exl_mark expected') }
	}
}
