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

pub fn (mut l Lowerer) gen_then_label() string {
	l.label_count++
	return 'Then_$l.label_count'
}

pub fn (mut l Lowerer) gen_else_label() string {
	l.label_count++
	return 'Else_$l.label_count'
}

pub fn (mut l Lowerer) gen_end_label() string {
	l.label_count++
	return 'End_$l.label_count'
}

pub fn (mut l Lowerer) gen_break_label() string {
	l.label_count++
	return 'Break_$l.label_count'
}

pub fn (mut l Lowerer) gen_cond_label() string {
	l.label_count++
	return 'Cond_$l.label_count'
}

pub fn (mut l Lowerer) gen_body_label() string {
	l.label_count++
	return 'Body_$l.label_count'
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
		BoundImportStmt { return stmt }
		BoundAssertStmt { return l.rewrite_assert_stmt(stmt) }
	}
}

fn (mut l Lowerer) rewrite_assert_stmt(stmt BoundAssertStmt) BoundStmt {
	lowered_expr := l.rewrite_expr(stmt.expr)
	return new_bound_assert_stmt(stmt.location, lowered_expr, stmt.code)
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
		// gotoTrue <condition> label_eq, label_end
		// label_eq:
		// 	<then>
		// goto label_end:
		// label_end:

		end_then_name := l.gen_then_label()
		end_label_name := l.gen_end_label()
		res := block(goto_cond(stmt.cond_expr, end_then_name, end_label_name), label(end_then_name),
			stmt.then_stmt, goto_label(end_label_name), label(end_label_name))

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

		// gotoTrue <condition> label_eq, label_not_eq
		// label_eq:
		// 	<then>
		//  goto end:
		// label_not_eq:
		//  <else>
		// goto end:
		// end:

		then_label := l.gen_then_label()
		else_label := l.gen_else_label()
		end_label := l.gen_end_label()

		res := block(goto_cond(stmt.cond_expr, then_label, else_label), label(then_label),
			stmt.then_stmt, goto_label(end_label), label(else_label), stmt.else_stmt,
			goto_label(end_label), label(end_label))

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
		// goto continue
		// continue:
		// gotoTrue <condition> body, break
		// break:
		continue_label := l.gen_continue_label()
		body_label := l.gen_body_label()
		break_label := l.gen_break_label()
		// end_label := l.gen_label()
		res := block(goto_label(continue_label), label(body_label), stmt.body_stmt, goto_label(continue_label),
			label(continue_label), goto_cond(stmt.cond_expr, body_label, break_label),
			label(break_label))
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
		// goto continue
		// continue:
		// goto body
		// break:
		continue_label := l.gen_continue_label()
		body_label := l.gen_label()
		break_label := l.gen_break_label()
		// end_label := l.gen_label()
		res := block(goto_label(body_label), label(body_label), stmt.body_stmt, goto_label(continue_label),
			label(continue_label), goto_label(body_label), label(break_label))
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
	//   goto continue
	//   continue:
	//   <var> = <var> + 1
	//   goto cond
	//   cond:
	//   gotoTrue <var> < upper body, break
	//   break:
	// }

	range := stmt.range_expr as BoundRangeExpr
	// mut var := lower
	lower_decl := var_decl(stmt.ident, range.from_expr, true)
	upper_decl := var_decl_local('upper', symbols.int_symbol, range.to_expr, false)

	continue_label := l.gen_continue_label()
	body_label := l.gen_body_label()
	break_label := l.gen_break_label()
	cond_label := l.gen_cond_label()

	res := block(lower_decl, upper_decl, goto_label(cond_label), label(body_label), stmt.body_stmt,
		goto_label(continue_label), label(continue_label), increment(variable(lower_decl)),
		goto_label(cond_label), label(cond_label), goto_cond(less_than(variable(lower_decl),
		variable(upper_decl)), body_label, break_label), label(break_label))
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
			rev_stmts := current.stmts.reverse()
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
	for old_stmt in stmt.stmts {
		new_stmt := l.rewrite_stmt(old_stmt)
		// for j := 0; j < i; j++ {
		// 	ret_block_stmt << stmt.stmts[j]
		// }
		ret_block_stmt << new_stmt
	}
	if ret_block_stmt.len == 0 {
		return stmt
	}
	return new_bound_block_stmt(ret_block_stmt)
}

fn (mut l Lowerer) rewrite_expr_stmt(stmt BoundExprStmt) BoundStmt {
	new_expr := l.rewrite_expr(stmt.expr)
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
	cond := l.rewrite_expr(stmt.cond_expr)
	return new_bound_cond_goto_stmt(cond, stmt.true_label, stmt.false_label)
}

pub fn (mut l Lowerer) rewrite_expr(expr BoundExpr) BoundExpr {
	match expr {
		BoundLiteralExpr { return l.rewrite_literal_expr(expr) }
		BoundUnaryExpr { return l.rewrite_unary_expr(expr) }
		BoundBinaryExpr { return l.rewrite_binary_expr(expr) }
		BoundAssignExpr { return l.rewrite_assign_expr(expr) }
		BoundIfExpr { return l.rewrite_if_expr(expr) }
		BoundRangeExpr { return l.rewrite_range_expr(expr) }
		BoundIndexExpr { return l.rewrite_index_expr(expr) }
		BoundVariableExpr { return l.rewrite_variable_expr(expr) }
		BoundErrorExpr { return l.rewrite_error_expr(expr) }
		BoundCallExpr { return l.rewrite_call_expr(expr) }
		BoundConvExpr { return l.rewrite_conv_expr(expr) }
		BoundNoneExpr { return expr }
		BoundArrayInitExpr { return expr }
		BoundStructInitExpr { return expr }
		NoneExpr { return expr }
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

	return new_bound_call_expr(expr.func, expr.receiver, rewritten_args, expr.is_c_call)
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
	operand := l.rewrite_expr(expr.operand_expr)
	return new_bound_unary_expr(expr.op, operand)
}

pub fn (mut l Lowerer) rewrite_binary_expr(expr BoundBinaryExpr) BoundExpr {
	left := l.rewrite_expr(expr.left_expr)
	right := l.rewrite_expr(expr.right_expr)
	return new_bound_binary_expr(left, expr.op, right)
}

pub fn (mut l Lowerer) rewrite_assign_expr(expr BoundAssignExpr) BoundExpr {
	rewritten_expr := l.rewrite_expr(expr.expr)
	return new_bound_assign_with_names_expr(expr.var, expr.names, rewritten_expr)
}

pub fn (mut l Lowerer) rewrite_range_expr(expr BoundRangeExpr) BoundExpr {
	return expr
}

pub fn (mut l Lowerer) rewrite_index_expr(expr BoundIndexExpr) BoundExpr {
	rewritten_left_expr := l.rewrite_expr(expr.left_expr)
	rewritten_index_expr := l.rewrite_expr(expr.index_expr)
	return new_bound_index_expr(rewritten_left_expr, rewritten_index_expr)
}
