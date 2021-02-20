module comp

import lib.comp.binding
import lib.comp.types


pub struct Evaluator {
	root binding.BoundStmt
mut:
	vars &binding.EvalVariables
	last_val types.LitVal
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
	}
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
	}
}

fn (mut e Evaluator) eval_bound_unary_expr(node binding.BoundUnaryExpression) ?types.LitVal {
	operand := e.eval_expr(node.operand) ?
	match node.op.op_kind {
		.identity { return operand as int }
		.negation { return -(operand as int) }
		.logic_negation { return !(operand as bool) }
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
		.equals { return left.eq(right) }
		.not_equals { return !left.eq(right) }
		else { panic('operator <$node.op.op_kind> exl_mark expected') }
	}
}

fn (mut e Evaluator) eval_bound_assign_expr(node binding.BoundAssignExpr) ?types.LitVal {
	val := e.eval_expr(node.expr) ?
	e.vars.assign_variable_value(node.var, val)
	return val
}

fn (mut e Evaluator) eval_bound_literal_expr(root binding.BoundLiteralExpr) ?types.LitVal {
	return root.val
}

fn (mut e Evaluator) eval_bound_variable_expr(root binding.BoundVariableExpr) ?types.LitVal {
	var :=  e.vars.lookup(root.var) or {return none}
	return var
}

