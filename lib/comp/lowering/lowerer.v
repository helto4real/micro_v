// lowering module handles all conversions from the AST node to lower constructs
// that can be handled by later stages.
// TODO: optimize the lowering so when expressions and statements are not lowered
//		 no new BoundNode is created
module lowering

import lib.comp.binding
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

pub fn lower(stmt binding.BoundStmt) binding.BoundBlockStmt {
	mut lowerer := new_lowerer(false)
	result := lowerer.rewrite_stmt(stmt)
	return flatten(result)
}

// lower just the nodes in first level
pub fn lower_shallow(stmt binding.BoundStmt) binding.BoundBlockStmt {
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

pub fn (mut l Lowerer) rewrite_stmt(stmt binding.BoundStmt) binding.BoundStmt {
	match stmt {
		binding.BoundBlockStmt { return l.rewrite_block_stmt(stmt) }
		binding.BoundExprStmt { return l.rewrite_expr_stmt(stmt) }
		binding.BoundForRangeStmt { return l.rewrite_for_range_stmt(stmt) }
		binding.BoundForStmt { return l.rewrite_for_stmt(stmt) }
		binding.BoundIfStmt { return l.rewrite_if_stmt(stmt) }
		binding.BoundVarDeclStmt { return l.rewrite_var_decl_stmt(stmt) }
		binding.BoundLabelStmt { return l.rewrite_label_stmt(stmt) }
		binding.BoundGotoStmt { return l.rewrite_goto_stmt(stmt) }
		binding.BoundCondGotoStmt { return l.rewrite_cond_goto_stmt(stmt) }
		binding.BoundBreakStmt { return l.rewrite_break_stmt(stmt) }
		binding.BoundContinueStmt { return l.rewrite_continue_stmt(stmt) }
	}
}

fn (mut l Lowerer) rewrite_break_stmt(stmt binding.BoundBreakStmt) binding.BoundStmt {
	bc_labels := l.break_cont_stack.peek() or {panic('unexpected empty stack')}
	return l.rewrite_stmt(binding.new_bound_goto_stmt(bc_labels.break_label))
}

fn (mut l Lowerer) rewrite_continue_stmt(stmt binding.BoundContinueStmt) binding.BoundStmt {
	bc_labels := l.break_cont_stack.peek() or {panic('unexpected empty stack')}
	return l.rewrite_stmt(binding.new_bound_goto_stmt(bc_labels.continue_label))
}

fn (mut l Lowerer) rewrite_if_stmt(stmt binding.BoundIfStmt) binding.BoundStmt {
	// return binding.BoundStmt(stmt)
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

pub fn (mut l Lowerer) rewrite_if_expr(expr binding.BoundIfExpr) binding.BoundExpr {
	cond_expr := l.rewrite_expr(expr.cond_expr)
	then_stmt := l.rewrite_stmt(expr.then_stmt)
	else_stmt := l.rewrite_stmt(expr.else_stmt)

	return binding.new_if_else_expr(cond_expr, then_stmt, else_stmt)
}

// fn (mut l Lowerer) rewrite_if_expr(expr binding.BoundIfExpr) binding.BoundStmt {

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

fn (mut l Lowerer) rewrite_for_stmt(stmt binding.BoundForStmt) binding.BoundStmt {
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
		res := block(
			goto_label(continue_label), 
			label(body_label), 
			stmt.body_stmt, 
			label(continue_label),
			goto_true(body_label, stmt.cond_expr),
			label(break_label))
		if l.shallow {
			return res
		}
		l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
		body := l.rewrite_stmt(res)
		l.break_cont_stack.pop() or {panic('unexepected empty stack')}
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
		res := block(
			label(body_label), 
			stmt.body_stmt, 
			label(continue_label),
			goto_label(body_label),
			label(break_label))
		if l.shallow {
			return res
		}
		l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
		body := l.rewrite_stmt(res)
		l.break_cont_stack.pop() or {panic('unexepected empty stack')}
		return body
	}
	return stmt
}

fn (mut l Lowerer) rewrite_for_range_stmt(stmt binding.BoundForRangeStmt) binding.BoundStmt {
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
	
	
	range := stmt.range_expr as binding.BoundRangeExpr
	// mut var := lower
	lower_decl := var_decl(stmt.ident, range.from_exp, true)
	upper_decl := var_decl_local('upper', symbols.int_symbol, range.to_exp, false)
	
	continue_label := l.gen_continue_label()
	body_label := l.gen_label()
	break_label := l.gen_break_label()
	cond_label := l.gen_label()
	
	res := block(
			lower_decl, 
			upper_decl,
			goto_label(cond_label),  
			label(body_label),
			stmt.body_stmt, 
			label(continue_label),
			increment(variable(lower_decl)),
			label(cond_label),
			goto_true(
				body_label, 	
				less_than(
					variable(lower_decl), 
					variable(upper_decl)
				)
			),
			label(break_label)
		)
	if l.shallow {
		return res
	}

	l.break_cont_stack.push(new_break_and_cont_labels(break_label, continue_label))
	body := l.rewrite_stmt(res)
	l.break_cont_stack.pop() or {panic('unexepected empty stack')}
	return body
}

pub fn flatten(stmt binding.BoundStmt) binding.BoundBlockStmt {
	// mut stack := []binding.BoundStmt{cap: 100}
	mut stack := BoundStmtStack{}
	mut flattened_stmts := []binding.BoundStmt{cap: 100}
	stack.push(stmt)

	for !stack.is_empty() {
		current := stack.pop() or { panic('as') }
		if current is binding.BoundBlockStmt {
			rev_stmts := current.bound_stmts.reverse()
			for s in rev_stmts {
				stack.push(s)
			}
		} else {
			flattened_stmts << current
		}
	}
	return binding.new_bound_block_stmt(flattened_stmts)
}
