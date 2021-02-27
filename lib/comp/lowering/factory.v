module lowering

import lib.comp.binding

fn block(stmts ...binding.BoundStmt) binding.BoundStmt {
	return binding.new_bound_block_stmt(stmts)
}

fn goto_false(label string, expr binding.BoundExpr) binding.BoundStmt {
	return binding.new_bound_cond_goto_stmt(label, expr, false) 
}

fn goto_true(label string, expr binding.BoundExpr) binding.BoundStmt {
	return binding.new_bound_cond_goto_stmt(label, expr, true)
}

fn goto_label(label string) binding.BoundStmt {
	return binding.new_bound_goto_stmt(label)
}
fn label(label string) binding.BoundStmt {
	return binding.new_bound_label_stmt(label)
}

fn var_decl(var &binding.VariableSymbol, expr binding.BoundExpr, is_mut bool) binding.BoundStmt {
	// new_variable_symbol(name string, typ types.Type, is_mut bool)
	// new_variable_symbol
	return binding.new_var_decl_stmt(var, expr, is_mut)
}