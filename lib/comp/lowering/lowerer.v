module lowering

import lib.comp.binding

pub struct Lowerer {
mut:
	label_count int
}

pub fn new_lowerer() Lowerer {
	return Lowerer{}
}

pub fn lower(stmt binding.BoundStmt) binding.BoundBlockStmt {
	mut lowerer := new_lowerer()
	result := lowerer.rewrite_stmt(stmt)
	return flatten(result)
}

pub fn (mut l Lowerer) gen_label() string {
	l.label_count++
	return 'Label_$l.label_count'
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
	}
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
		goto_end_if_false := binding.new_bound_cond_goto_stmt(end_label_name, stmt.cond_expr,
			false)
		end_label := binding.new_bound_label_stmt(end_label_name)
		stmts := [goto_end_if_false, stmt.block_stmt, end_label]
		res := binding.new_bound_block_stmt(stmts)
		rewritten := l.rewrite_stmt(res)
		return rewritten
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
		else_label_name := l.gen_label()
		end_label_name := l.gen_label()

		goto_else_if_false := binding.new_bound_cond_goto_stmt(else_label_name, stmt.cond_expr,
			false)
		goto_end := binding.new_bound_goto_stmt(end_label_name)
		else_label := binding.new_bound_label_stmt(else_label_name)
		end_label := binding.new_bound_label_stmt(end_label_name)

		stmts := [
			goto_else_if_false,
			stmt.block_stmt,
			goto_end,
			else_label,
			stmt.else_clause,
			end_label,
		]

		res := binding.new_bound_block_stmt(stmts)
		rewritten := l.rewrite_stmt(res)
		return rewritten
	}
}

pub fn (mut l Lowerer) rewrite_if_expr(expr binding.BoundIfExpr) binding.BoundExpr {
	cond_expr := l.rewrite_expr(expr.cond_expr)
	then_stmt := l.rewrite_stmt(expr.then_stmt)
	else_stmt := l.rewrite_stmt(expr.else_stmt)

	return binding.new_if_else_expr(cond_expr, then_stmt, else_stmt)
}

pub fn flatten(stmt binding.BoundStmt) binding.BoundBlockStmt {
	mut stack := []binding.BoundStmt{cap: 100}
	mut flattened_stmts := []binding.BoundStmt{cap: 100}
	stack.push(stmt)

	for stack.len > 0 {
		current := stack.pop()
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
