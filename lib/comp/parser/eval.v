module parser

import lib.comp.binding
import lib.comp.types

pub struct Evaluator {
	root binding.BoundExpr
}

pub fn new_evaluator(root binding.BoundExpr) Evaluator {
	return Evaluator {
		root: root
	}
}

pub fn (mut e Evaluator) evaluate() ?types.LitVal {
	return e.eval_expr(e.root)
}

fn (mut e Evaluator) eval_expr(root binding.BoundExpr) ?types.LitVal {
	match root {
		binding.BoundLiteralExpr {
			return root.val
		}
		binding.BoundUnaryExpression {
			operand := e.eval_expr(root.operand) ?
			operand_int := operand as int
			match root.op_kind {
				.identity {	return operand_int } 
				.negation {	return -operand_int	} 
				else {panic('unexpected unary token $root.op_kind')}
			} 
		}
		binding.BoundBinaryExpr {
			left := e.eval_expr(root.left) ? 
			right := e.eval_expr(root.right) ? 
			left_int := left as int
			right_int := right as int
			match root.op_kind {
				.addition {return left_int + right_int}
				.subraction {return left_int - right_int}
				.multiplication {return left_int * right_int}
				.divition {return left_int / right_int}
				else {panic('operator <$root.op_kind> not expected')}
			}
		}
		// ast.ParaExpr {
		// 	return e.eval_expr(root.expr) 
		// }
		// ast.EmptyExpr {
		// 	return error('NoneExpr should never occur, parser bug.')
		// }
	}
}