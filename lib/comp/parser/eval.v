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
			match root.op.op_kind {
				.identity { return operand as int } 
				.negation {	return -(operand as int) } 
				.logic_negation { return !(operand as bool) } 
				else {panic('unexpected unary token $root.op.op_kind')}
			} 
		}
		binding.BoundBinaryExpr {
			left := e.eval_expr(root.left) ? 
			right := e.eval_expr(root.right) ? 
			// compiler bug does not work with normal cast
			match root.op.op_kind {
				.addition {return (left as int) + (right as int)}
				.subraction {return (left as int) - (right as int)}
				.multiplication {return (left as int) * (right as int)}
				.divition {return (left as int) / (right as int)}
				.logic_and {return (left as bool) && (right as bool)}
				.logic_or {return (left as bool) || (right as bool)}
				else {panic('operator <$root.op.op_kind> not expected')}
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