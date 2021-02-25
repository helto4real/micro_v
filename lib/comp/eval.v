module comp

import strings
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
	e.eval_stmt(e.root)
	return e.last_val
	// return e.eval_stmt(e.root)
}

fn (mut e Evaluator) eval_stmt(stmt binding.BoundStmt) {
	match stmt {
		binding.BoundBlockStmt {
			e.eval_bound_block_stmt(stmt)
		}
		binding.BoundExprStmt {
			e.eval_bound_expr_stmt(stmt)
		}
		binding.BoundVarDeclStmt {
			e.eval_bound_var_decl_stmt(stmt)
		}
		binding.BoundIfStmt {
			e.eval_bound_if_stmt(stmt)
		}
		binding.BoundForRangeStmt {
			e.eval_bound_for_range_stmt(stmt)
		}
		binding.BoundForStmt {
			e.eval_bound_for_stmt(stmt)
		}
	}
}

// TODO: Will remove the print out of these functions onces println is implemented
fn (mut e Evaluator) eval_bound_for_stmt(node binding.BoundForStmt) {
	mut b := strings.new_builder(0)
	mut first_loop := true
	for {
		if node.has_cond {
			cond_expr := e.eval_expr(node.cond_expr) or {
				panic('unexpected error evaluate expression')
			}
			if (cond_expr as bool) == false {
				break
			}
		}
		e.eval_stmt(node.body_stmt)
		if !first_loop {
			b.write_string('   ')
		}
		b.writeln('$e.last_val')
		first_loop = false
	}
	e.last_val = b.str()
}

fn (mut e Evaluator) eval_bound_for_range_stmt(node binding.BoundForRangeStmt) {
	range_expr := node.range_expr as binding.BoundRangeExpr
	from := e.eval_expr(range_expr.from_exp) or { panic('unexpected eval expression') }
	to := e.eval_expr(range_expr.to_exp) or { panic('unexpected eval expression') }

	mut b := strings.new_builder(0)
	if from is int {
		to_int := to as int
		for i in from .. to_int {
			e.vars.assign_variable_value(node.ident, i)
			// println('ident: $ident, range_expr: $range_expr')
			e.eval_stmt(node.body_stmt)
			if i != from {
				b.write_string('   ')
			}
			b.writeln('$e.last_val')
		}
	}
	// val := types.LitVal(b.str())
	e.last_val = b.str()
}
fn (mut e Evaluator) eval_bound_if_stmt(node binding.BoundIfStmt) {
	cond_expr := e.eval_expr(node.cond_expr) or { panic('unexpected compiler error') }

	if cond_expr is bool {
		if cond_expr == true {
			e.eval_stmt(node.block_stmt)
		} else if node.has_else {
			e.eval_stmt(node.else_clause)
		}
	} else {
		panic('unexpected type in if condition')
	}
}
fn (mut e Evaluator) eval_bound_var_decl_stmt(node binding.BoundVarDeclStmt) {
	val := e.eval_expr(node.expr) or { panic('unexpected compiler error') }
	e.vars.assign_variable_value(node.var, val)
	e.last_val = val
}

fn (mut e Evaluator) eval_bound_block_stmt(block_stmt binding.BoundBlockStmt) {
	for stmt in block_stmt.bound_stmts {
		e.eval_stmt(stmt)
	}
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
		binding.BoundUnaryExpression {
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
		binding.BoundIfExpr {
			return e.eval_bound_if_expr(node)
		}
		binding.BoundRangeExpr {
			return e.eval_bound_range_expr(node)
		}
	}
}

fn (mut e Evaluator) eval_bound_range_expr(node binding.BoundRangeExpr) ?types.LitVal {
	from_val := e.eval_expr(node.from_exp) ?
	to_val := e.eval_expr(node.to_exp) ?
	return '${from_val as int}..${to_val as int}'
}

fn (mut e Evaluator) eval_bound_if_expr(node binding.BoundIfExpr) ?types.LitVal {
	cond_expr := e.eval_expr(node.cond_expr) or { panic('unexpected compiler error') }

	if cond_expr is bool {
		if cond_expr == true {
			e.eval_stmt(node.then_stmt)
		} else {
			e.eval_stmt(node.else_stmt)
		}
	} else {
		panic('unexpected type in if condition')
	}
	return e.last_val
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

fn (mut e Evaluator) eval_bound_unary_expr(node binding.BoundUnaryExpression) ?types.LitVal {
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
		else { panic('operator <$node.op.op_kind> exl_mark expected') }
	}
}
