module parser

import lib.comp.ast

pub struct Evaluator {
	root ast.Expression
}

pub fn new_evaluator(root ast.Expression) Evaluator {
	return Evaluator {
		root: root
	}
}

pub fn (mut e Evaluator) evaluate() ?int {
	return e.eval_expr(e.root)
}

fn (mut e Evaluator) eval_expr(root ast.Expression) ?int {
	match root {
		ast.LiteralExpr {
			return root.val
		}
		ast.UnaryExpr {
			operand := e.eval_expr(root.operand) ?
			match root.op.kind {
				.plus {
					return operand
				} 
				.minus {
					return -operand
				} 
				else {panic('unexpected unary token $root.kind')}
			} 
		}
		ast.BinaryExpr {
			left := e.eval_expr(root.left) ?
			right := e.eval_expr(root.right) ?
			match root.op.kind {
				.plus {return left + right}
				.minus {return left - right}
				.mul {return left * right}
				.div {return left / right}
				else {panic('operator <$root.op.kind> not expected')}
			}
		}
		ast.ParaExpr {
			return e.eval_expr(root.expr) 
		}
		ast.EmptyExpr {
			return error('NoneExpr should never occur, parser bug.')
		}
	}
}