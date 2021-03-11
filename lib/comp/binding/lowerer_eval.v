// lowering module handles all conversions from the AST node to lower constructs
// that can be handled by later stages.
// TODO: optimize the lowering so when expressions and statements are not lowered
//		 no new BoundNode is created
module binding

import lib.comp.symbols

pub struct Lowerer {
mut:
	shallow          bool
	label_count      int
	break_cont_stack BreakAndContinueLabelStack
}

pub fn new_lowerer(shallow bool) Lowerer {
	return Lowerer{
		shallow: shallow
	}
}

pub fn lower(stmt BoundStmt) BoundBlockStmt {
	mut lowerer := new_lowerer(false)
	result := lowerer.rewrite_stmt(stmt)
	return flatten(result)
}

// lower just the nodes in first level
pub fn lower_shallow(stmt BoundStmt) BoundBlockStmt {
	mut lowerer := new_lowerer(true)
	result := lowerer.rewrite_stmt(stmt)
	return flatten(result)
}

pub fn (mut l Lowerer) gen_label() string {
	l.label_count++
	return 'Label_$l.label_count'
}

pub fn (mut l Lowerer) gen_break_label() string {
	l.label_count++
	return 'Break_$l.label_count'
}

pub fn (mut l Lowerer) gen_continue_label() string {
	l.label_count++
	return 'Continue_$l.label_count'
}

pub fn (mut l Lowerer) rewrite_stmt(stmt BoundStmt) BoundStmt {
	match stmt {
		BoundBlockStmt { return l.rewrite_block_stmt(stmt) }
		BoundExprStmt { return l.rewrite_expr_stmt(stmt) }
		BoundForRangeStmt { return l.rewrite_for_range_stmt(stmt) }
		BoundForStmt { return l.rewrite_for_stmt(stmt) }
		BoundIfStmt { return l.rewrite_if_stmt(stmt) }
		BoundVarDeclStmt { return l.rewrite_var_decl_stmt(stmt) }
		BoundLabelStmt { return l.rewrite_label_stmt(stmt) }
		BoundGotoStmt { return l.rewrite_goto_stmt(stmt) }
		BoundCondGotoStmt { return l.rewrite_cond_goto_stmt(stmt) }
		BoundBreakStmt { return l.rewrite_break_stmt(stmt) }
		BoundContinueStmt { return l.rewrite_continue_stmt(stmt) }
		BoundReturnStmt { return l.rewrite_return_stmt(stmt) }
		BoundCommentStmt { return stmt }
		BoundModuleStmt { return stmt }
	}
}

fn (mut l Lowerer) rewrite_return_stmt(stmt BoundReturnStmt) BoundStmt {
	if stmt.has_expr {
		expr := l.rewrite_expr(stmt.expr)
		return new_bound_return_with_expr_stmt(expr)
	} else {
		return stmt
	}
}

fn (mut l Lowerer) rewrite_break_stmt(stmt BoundBreakStmt) BoundStmt {
	bc_labels := l.break_cont_stack.peek() or { panic('unexpected empty stack') }
	return l.rewrite_stmt(new_bound_goto_stmt(bc_labels.break_label))
}

fn (mut l Lowerer) rewrite_continue_stmt(stmt BoundContinueStmt) BoundStmt {
	bc_labels := l.break_cont_stack.peek() or { panic('unexpected empty stack') }
	return l.rewrite_stmt(new_bound_goto_stmt(bc_labels.continue_label))
}

fn (mut l Lowerer) rewrite_if_stmt(stmt BoundIfStmt) BoundStmt {
	// return BoundStmt(stmt)
	if stmt.has_else == false {
		// if <condition>
		//      <then>
		//
		// ---->
		//
		// gotoFalse <condition> end
		// <then>
		// end:		

		end_label_name := l.gen_label()
		res := block(goto_false(end_label_name, stmt.cond_expr), stmt.block_stmt, label(end_label_name))

		if l.shallow {
			return res
		}
		return l.rewrite_stmt(res)
	} else {
		// if <condition>
		//      <then>
		// else
		//      <else>
		//
		// ---->
		//
		// gotoFalse <condition> else
		// <then>
		// goto end
		// else:
		// <else>
		// end:
		// else_label_name := l.gen_label()
		// end_label_name := l.gen_label()

		else_label := l.gen_label()
		end_label := l.gen_label()

		res := block(goto_false(else_label, stmt.cond_expr), stmt.block_stmt, goto_label(end_label),
			label(else_label), stmt.else_clause, label(end_label))

		if l.shallow {
			return res
		}
		return l.rewrite_stmt(res)
	}
}

pub fn (mut l Lowerer) rewrite_if_expr(expr BoundIfExpr) BoundExpr {
	cond_expr := l.rewrite_expr(expr.cond_expr)
	then_stmt := l.rewrite_stmt(expr.then_stmt)
	else_stmt := l.rewrite_stmt(expr.else_stmt)

	return new_if_else_expr(cond_expr, then_stmt, else_stmt)
}

// fn (mut l Lowerer) rewrite_if_expr(expr BoundIfExpr) BoundStmt {

// 	// if <condition>
// 	//      <then>
// 	// else
// 	//      <else>
// 	//
// 	// ---->
// 	//
// 	// gotoFalse <condition> else
// 	// <then>
// 	// goto end
// 	// else:
// 	// <else>
// 	// end:
// 	// else_label_name := l.gen_label()
// 	// end_label_name := l.gen_label()

// 	else_label := l.gen_label()
// 	end_label := l.gen_label()

// 	res := block_expr(
// 		goto_false(else_label, expr.cond_expr), 
// 		expr.then_stmt, 
// 		goto_label(end_label),
// 		label(else_label), 
// 		expr.else_stmt, 
// 		label(end_label)
// 		)

// 	if l.shallow {
// 		return res
// 	}
// 	return l.rewrite_stmt(res)
// }

fn (mut l Lowerer) rewrite_for_stmt(stmt BoundForStmt) BoundStmt {
	if stmt.has_cond {
		// this is a 'for expr {}'

		// for <condition>
		//      <body>
		//
		// ----->
		//
		// goto continue
		// body:
		// <body>
		// continue:
		// gotoTrue <condition> body
		// break:
		continue_label := l.gen_continue_label()
		body_label := l.gen_label()
		break_label := l.gen_break_label()
		// end_label := l.gen_label()
		res := block(goto_label(continue_label), label(body_label), stmt.body_stmt, label(continue_label),
			goto_true(body_label, stmt.cond_expr), label(break_label))
		if l.shallow {
			return res
		}
		l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
		body := l.rewrite_stmt(res)
		l.break_cont_stack.pop() or { panic('unexepected empty stack') }
		return body
	} else {
		// this is a 'for {}' i.e. a while loop

		// for <condition>
		//      <body>
		//
		// ----->
		//
		// body:
		// <body>
		// continue:
		// goto body
		// break:
		continue_label := l.gen_continue_label()
		body_label := l.gen_label()
		break_label := l.gen_break_label()
		// end_label := l.gen_label()
		res := block(label(body_label), stmt.body_stmt, label(continue_label), goto_label(body_label),
			label(break_label))
		if l.shallow {
			return res
		}
		l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
		body := l.rewrite_stmt(res)
		l.break_cont_stack.pop() or { panic('unexepected empty stack') }
		return body
	}
	return stmt
}

fn (mut l Lowerer) rewrite_for_range_stmt(stmt BoundForRangeStmt) BoundStmt {
	// The for range is transformed it two stages, this stage transforms it
	// to a normal for statement

	// for <var> in <lower>..<upper>
	//      <body>
	//
	// ----->
	// {
	//   mut var := <lower>
	//   upper := <upper>
	//   goto cond
	//   body:
	//   <body>
	//   continue:
	//   <var> = <var> + 1
	//   cond:
	//   gotoTrue <var> < upper body
	//   break:
	// }

	range := stmt.range_expr as BoundRangeExpr
	// mut var := lower
	lower_decl := var_decl(stmt.ident, range.from_exp, true)
	upper_decl := var_decl_local('upper', symbols.int_symbol, range.to_exp, false)

	continue_label := l.gen_continue_label()
	body_label := l.gen_label()
	break_label := l.gen_break_label()
	cond_label := l.gen_label()

	res := block(lower_decl, upper_decl, goto_label(cond_label), label(body_label), stmt.body_stmt,
		label(continue_label), increment(variable(lower_decl)), label(cond_label), goto_true(body_label,
		less_than(variable(lower_decl), variable(upper_decl))), label(break_label))
	if l.shallow {
		return res
	}

	l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
	body := l.rewrite_stmt(res)
	l.break_cont_stack.pop() or { panic('unexepected empty stack') }
	return body
}

pub fn flatten(stmt BoundStmt) BoundBlockStmt {
	// mut stack := []BoundStmt{cap: 100}
	mut stack := BoundStmtStack{}
	mut flattened_stmts := []BoundStmt{cap: 100}
	stack.push(stmt)

	for !stack.is_empty() {
		current := stack.pop() or { panic('as') }
		if current is BoundBlockStmt {
			rev_stmts := current.bound_stmts.reverse()
			for s in rev_stmts {
				stack.push(s)
			}
		} else {
			flattened_stmts << current
		}
	}
	return new_bound_block_stmt(flattened_stmts)
}

/*
Not lowered
*/

fn (mut l Lowerer) rewrite_block_stmt(stmt BoundBlockStmt) BoundStmt {
	mut ret_block_stmt := []BoundStmt{}
	for old_stmt in stmt.bound_stmts {
		new_stmt := l.rewrite_stmt(old_stmt)
		// for j := 0; j < i; j++ {
		// 	ret_block_stmt << stmt.bound_stmts[j]
		// }
		ret_block_stmt << new_stmt
	}
	if ret_block_stmt.len == 0 {
		return stmt
	}
	return new_bound_block_stmt(ret_block_stmt)
}

fn (mut l Lowerer) rewrite_expr_stmt(stmt BoundExprStmt) BoundStmt {
	new_expr := l.rewrite_expr(stmt.bound_expr)
	return new_bound_expr_stmt(new_expr)
}

fn (mut l Lowerer) rewrite_var_decl_stmt(stmt BoundVarDeclStmt) BoundStmt {
	new_expr := l.rewrite_expr(stmt.expr)
	return new_var_decl_stmt(stmt.var, new_expr, stmt.is_mut)
}

fn (mut l Lowerer) rewrite_label_stmt(stmt BoundLabelStmt) BoundStmt {
	return stmt
}

fn (mut l Lowerer) rewrite_goto_stmt(stmt BoundGotoStmt) BoundStmt {
	return stmt
}

fn (mut l Lowerer) rewrite_cond_goto_stmt(stmt BoundCondGotoStmt) BoundStmt {
	cond := l.rewrite_expr(stmt.cond)
	return new_bound_cond_goto_stmt(stmt.label, cond, stmt.jump_if_true)
}

pub fn (mut l Lowerer) rewrite_expr(expr BoundExpr) BoundExpr {
	match expr {
		BoundLiteralExpr { return l.rewrite_literal_expr(expr) }
		BoundUnaryExpr { return l.rewrite_unary_expr(expr) }
		BoundBinaryExpr { return l.rewrite_binary_expr(expr) }
		BoundAssignExpr { return l.rewrite_assign_expr(expr) }
		BoundIfExpr { return l.rewrite_if_expr(expr) }
		BoundRangeExpr { return l.rewrite_range_expr(expr) }
		BoundVariableExpr { return l.rewrite_variable_expr(expr) }
		BoundErrorExpr { return l.rewrite_error_expr(expr) }
		BoundCallExpr { return l.rewrite_call_expr(expr) }
		BoundConvExpr { return l.rewrite_conv_expr(expr) }
		BoundEmptyExpr { return expr }
	}
}

pub fn (mut l Lowerer) rewrite_conv_expr(expr BoundConvExpr) BoundExpr {
	rewritten_expr := l.rewrite_expr(expr.expr)
	return new_bound_conv_expr(expr.typ, rewritten_expr)
}

pub fn (mut l Lowerer) rewrite_call_expr(expr BoundCallExpr) BoundExpr {
	mut rewritten_args := []BoundExpr{}

	for arg in expr.params {
		rewritten_args << l.rewrite_expr(arg)
	}

	return new_bound_call_expr(expr.func, rewritten_args)
}

pub fn (mut l Lowerer) rewrite_error_expr(expr BoundErrorExpr) BoundExpr {
	return expr
}

pub fn (mut l Lowerer) rewrite_variable_expr(expr BoundVariableExpr) BoundExpr {
	return expr
}

pub fn (mut l Lowerer) rewrite_literal_expr(expr BoundLiteralExpr) BoundExpr {
	return expr
}

pub fn (mut l Lowerer) rewrite_unary_expr(expr BoundUnaryExpr) BoundExpr {
	operand := l.rewrite_expr(expr.operand)
	return new_bound_unary_expr(expr.op, operand)
}

pub fn (mut l Lowerer) rewrite_binary_expr(expr BoundBinaryExpr) BoundExpr {
	left := l.rewrite_expr(expr.left)
	right := l.rewrite_expr(expr.right)
	return new_bound_binary_expr(left, expr.op, right)
}

pub fn (mut l Lowerer) rewrite_assign_expr(expr BoundAssignExpr) BoundExpr {
	rewritten_expr := l.rewrite_expr(expr.expr)
	return new_bound_assign_expr(expr.var, rewritten_expr)
}

pub fn (mut l Lowerer) rewrite_range_expr(expr BoundRangeExpr) BoundExpr {
	return expr
}
