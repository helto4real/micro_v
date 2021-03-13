// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.token
import lib.comp.util.source
import lib.comp.symbols
import lib.comp.binding.convertion

[heap]
pub struct Binder {
pub mut:
	scope   &BoundScope = 0
	func    symbols.FunctionSymbol
	log     &source.Diagnostics // errors when parsing
	mod     string
	is_loop bool
	mod_ok_to_define bool = true // if true it is ok to define a module 
}

pub fn new_binder(parent &BoundScope, func symbols.FunctionSymbol) &Binder {
	mut scope := new_bound_scope(parent)
	new_binder := &Binder{
		scope: scope
		log: source.new_diagonistics()
		func: func
	}
	for param in func.params {
		scope.try_declare_var(param)
	}
	return new_binder
}

pub fn bind_program(global_scope &BoundGlobalScope) BoundProgram {
	parent_scope := create_parent_scope(global_scope)
	mut func_bodies := map[string]BoundBlockStmt{}
	mut log := source.new_diagonistics()
	for func in global_scope.funcs {
		mut binder := new_binder(parent_scope, func)
		fn_decl := binder.scope.lookup_fn_decl(func.name) or {
			panic('unexpected missing fn_decl in scope')
		}
		body := binder.bind_stmt(fn_decl.block)
		if func.typ != symbols.void_symbol && !all_path_return_in_body(body as BoundBlockStmt) {
			binder.log.error_all_paths_must_return(fn_decl.ident.pos)
		}
		func_bodies[func.id] = body as BoundBlockStmt
		log.all << binder.log.all
	}
	bound_program := new_bound_program(log, global_scope.stmt, func_bodies)
	return bound_program
}

pub fn bind_global_scope(previous &BoundGlobalScope, comp_node &ast.CompNode) &BoundGlobalScope {
	parent_scope := create_parent_scope(previous)
	mut binder := new_binder(parent_scope, symbols.undefined_fn)
	// first bind the functions to make them visible 
	for node in comp_node.members {
		if node is ast.FnDeclNode {
			binder.bind_fn_decl(node)
		}
	}
	// then bind the global statements
	mut glob_stmts := []BoundStmt{}

	for node in comp_node.members {
		if node is ast.GlobStmt {
			s := binder.bind_stmt(node.stmt)
			glob_stmts << s
		}
	}
	stmt := new_bound_block_stmt(glob_stmts)
	fns := binder.scope.funcs()
	fn_decls := binder.scope.func_decls()
	vars := binder.scope.vars()
	mut diagnostics := binder.log.all
	if previous != 0 && previous.log.all.len > 0 {
		diagnostics.prepend(previous.log.all)
	}

	return new_bound_global_scope(previous, binder.log, fns, fn_decls, vars, stmt)
}

fn create_parent_scope(previous &BoundGlobalScope) &BoundScope {
	mut stack := new_bound_global_scope_stack()
	mut prev := previous

	for prev != 0 {
		stack.push(prev)
		prev = prev.previous
	}
	mut parent := create_root_scope()

	for !stack.is_empty() {
		prev = stack.pop() or { &BoundGlobalScope(0) }
		if prev == 0 {
			panic('unexpected return from stack')
		}
		mut scope := new_bound_scope(parent)
		for i, glob_fn in prev.funcs {
			fn_decl := prev.fn_decls[i]
			scope.try_declare_fn(glob_fn, fn_decl)
		}
		for var in prev.vars {
			scope.try_declare_var(var)
		}
		parent = scope
	}

	return parent
}

fn create_root_scope() &BoundScope {
	mut result := new_bound_scope(&BoundScope(0))
	for f in symbols.built_in_functions {
		result.try_declare_glob_fn(f)
	}
	return result
}

pub fn (mut b Binder) bind_stmt(stmt ast.Stmt) BoundStmt {
	if b.mod_ok_to_define && stmt.kind != .comment_stmt && stmt.kind != .module_stmt {
		b.mod_ok_to_define = false
	}
	match stmt.kind {
		.block_stmt { return b.bind_block_stmt(stmt as ast.BlockStmt) }
		.for_range_stmt { return b.bind_for_range_stmt(stmt as ast.ForRangeStmt) }
		.if_stmt { return b.bind_if_stmt(stmt as ast.IfStmt) }
		.expr_stmt { return b.bind_expr_stmt(stmt as ast.ExprStmt) }
		.var_decl_stmt { return b.bind_var_decl_stmt(stmt as ast.VarDeclStmt) }
		.for_stmt { return b.bind_for_stmt(stmt as ast.ForStmt) }
		.cont_stmt { return b.bind_continue_stmt(stmt as ast.ContinueStmt) }
		.break_stmt { return b.bind_break_stmt(stmt as ast.BreakStmt) }
		.return_stmt { return b.bind_return_stmt(stmt as ast.ReturnStmt) }
		.comment_stmt { return new_bound_comment_stmt((stmt as ast.CommentStmt).comment_tok) }
		.module_stmt { return b.bind_module_stmt(stmt as ast.ModuleStmt) }
		else { panic('unexpected stmt kind: $stmt.kind') }
	}
}

pub fn (mut b Binder) bind_module_stmt(module_stmt ast.ModuleStmt) BoundStmt {
	if b.mod.len > 0 {
		b.log.error_module_can_only_be_defined_once(module_stmt.pos)
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	if !b.mod_ok_to_define {
		b.log.error_module_can_only_be_defined_as_first_statement(module_stmt.pos)
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	b.mod = module_stmt.tok_name.lit
	return new_bound_module_stmt(module_stmt.tok_name)
}

pub fn (mut b Binder) bind_fn_decl(fn_decl ast.FnDeclNode) {
	mut params := []symbols.ParamSymbol{}
	mut seen_param_names := []string{}
	for i := 0; i < fn_decl.params.len(); i++ {
		param_node := fn_decl.params.at(i) as ast.ParamNode
		name := param_node.ident.lit
		param_typ := b.bind_type(param_node.typ)
		if name in seen_param_names {
			b.log.error_param_allready_declared(name, param_node.ident.pos)
		} else {
			param_symbol := symbols.new_param_symbol(name, param_typ, param_node.is_mut)
			params << param_symbol
			seen_param_names << name
		}
	}

	typ := if !fn_decl.typ_node.is_void {
		b.bind_type(fn_decl.typ_node)
	} else {
		symbols.void_symbol
	}

	func := symbols.new_function_symbol(fn_decl.ident.lit, params, typ)

	// TODO: refactor this. Due to V bug the func could not
	//		 include the decl
	if !b.scope.try_declare_fn(func, fn_decl) {
		b.log.error_function_allready_declared(fn_decl.ident.lit, fn_decl.ident.pos)
	}
}

pub fn (mut b Binder) bind_return_stmt(return_stmt ast.ReturnStmt) BoundStmt {
	// does the function have return typ
	// does the return type match?
	if b.func == symbols.undefined_fn {
		b.log.error_invalid_return(return_stmt.return_tok.pos)
	} else {
		if return_stmt.has_expr {
			mut expr := b.bind_expr(return_stmt.expr)
			if b.func.typ == symbols.void_symbol {
				// it is a subroutine
				b.log.error_invalid_return_expr(b.func.name, return_stmt.expr.pos)
			} else {
				expr = b.bind_convertion_diag(return_stmt.expr.pos, expr, b.func.typ)
			}
			return new_bound_return_with_expr_stmt(expr)
		} else {
			if b.func.typ != symbols.void_symbol {
				b.log.error_expected_return_value(b.func.typ.name, return_stmt.return_tok.pos)
			}
			return new_bound_return_stmt()
		}
	}
}

pub fn (mut b Binder) bind_continue_stmt(cont_stmt ast.ContinueStmt) BoundStmt {
	if b.is_loop == false {
		b.log.error_keyword_are_only_allowed_inside_a_loop('continue', cont_stmt.pos)
	}
	return new_bound_continue_stmt()
}

pub fn (mut b Binder) bind_break_stmt(break_stmt ast.BreakStmt) BoundStmt {
	if b.is_loop == false {
		b.log.error_keyword_are_only_allowed_inside_a_loop('break', break_stmt.pos)
	}
	return new_bound_break_stmt()
}

pub fn (mut b Binder) bind_for_stmt(for_stmt ast.ForStmt) BoundStmt {
	b.scope = new_bound_scope(b.scope)
	cond_expr := if for_stmt.has_cond {
		b.bind_expr_type(for_stmt.cond_expr, symbols.bool_symbol)
	} else {
		new_bound_emtpy_expr()
	}

	body_stmt := b.bind_loop_block_stmt(for_stmt.body_stmt as ast.BlockStmt)
	b.scope = b.scope.parent
	return new_for_stmt(cond_expr, body_stmt, for_stmt.has_cond)
}

pub fn (mut b Binder) bind_variable(ident token.Token, typ symbols.TypeSymbol, is_mut bool) symbols.VariableSymbol {
	name := ident.lit

	variable := if b.func == symbols.undefined_fn {
		// We are in global scope
		symbols.VariableSymbol(symbols.new_global_variable_symbol(name, typ, is_mut))
	} else {
		symbols.VariableSymbol(symbols.new_local_variable_symbol(name, typ, is_mut))
	}

	if !b.scope.try_declare_var(variable) {
		b.log.error_name_already_defined(name, ident.pos)
	}
	return variable
}

pub fn (mut b Binder) bind_for_range_stmt(for_range_stmt ast.ForRangeStmt) BoundStmt {
	range_expr := b.bind_expr(for_range_stmt.range_expr)
	b.scope = new_bound_scope(b.scope)

	ident := b.bind_variable(for_range_stmt.ident, range_expr.typ, false)
	body_stmt := b.bind_loop_block_stmt(for_range_stmt.body_stmt as ast.BlockStmt)
	b.scope = b.scope.parent
	return new_for_range_stmt(ident, range_expr, body_stmt)
}

pub fn (mut b Binder) bind_if_stmt(if_stmt ast.IfStmt) BoundStmt {
	cond_expr := b.bind_expr_type(if_stmt.cond_expr, symbols.bool_symbol)

	then_stmt := if_stmt.then_stmt as ast.BlockStmt
	bound_then_stmt := b.bind_block_stmt(then_stmt)

	if if_stmt.has_else {
		else_stmt := if_stmt.else_stmt as ast.BlockStmt
		bound_else_stmt := b.bind_block_stmt(else_stmt)
		return new_if_else_stmt(cond_expr, bound_then_stmt, bound_else_stmt)
	}
	return new_if_stmt(cond_expr, bound_then_stmt)
}

pub fn (mut b Binder) bind_loop_block_stmt(block_stmt ast.BlockStmt) BoundStmt {
	b.is_loop = true
	body_stmt := b.bind_block_stmt(block_stmt)
	b.is_loop = false
	return body_stmt
}

pub fn (mut b Binder) bind_block_stmt(block_stmt ast.BlockStmt) BoundStmt {
	b.scope = new_bound_scope(b.scope)
	mut stmts := []BoundStmt{}
	for blk in block_stmt.stmts {
		stmts << b.bind_stmt(blk)
	}
	b.scope = b.scope.parent
	return new_bound_block_stmt(stmts)
}

pub fn (mut b Binder) bind_expr_stmt(expr_stmt ast.ExprStmt) BoundStmt {
	expr := b.bind_expr(expr_stmt.expr)
	return new_bound_expr_stmt(expr)
}

pub fn (mut b Binder) bind_expr_type(expr ast.Expr, typ symbols.TypeSymbol) BoundExpr {
	return b.bind_convertion(typ, expr)
}

pub fn (mut b Binder) bind_expr(expr ast.Expr) BoundExpr {
	match expr {
		ast.LiteralExpr { return b.bind_literal_expr(expr) }
		ast.CallExpr { return b.bind_call_expr(expr) }
		ast.UnaryExpr { return b.bind_unary_expr(expr) }
		ast.BinaryExpr { return b.bind_binary_expr(expr) }
		ast.ParaExpr { return b.bind_para_expr(expr) }
		ast.NameExpr { return b.bind_name_expr(expr) }
		ast.AssignExpr { return b.bind_assign_expr(expr) }
		ast.IfExpr { return b.bind_if_expr(expr) }
		ast.RangeExpr { return b.bind_range_expr(expr) }
		else { panic('unexpected bound expression $expr') }
	}
}

fn lookup_type(name string) symbols.TypeSymbol {
	match name {
		'bool' { return symbols.bool_symbol }
		'int' { return symbols.int_symbol }
		'string' { return symbols.string_symbol }
		else { return symbols.none_symbol }
	}
}

pub fn (mut b Binder) bind_convertion_diag(diag_pos source.Pos, expr BoundExpr, typ symbols.TypeSymbol) BoundExpr {
	conv := convertion.classify(expr.typ, typ)
	if !conv.exists {
		// convertion does not exist
		if expr.typ != symbols.error_symbol && typ != symbols.error_symbol {
			b.log.error_cannot_convert_type(expr.typ.str(), typ.str(), diag_pos)
		}
		return new_bound_error_expr()
	}

	if conv.is_identity {
		return expr
	}
	return new_bound_conv_expr(typ, expr)
}

pub fn (mut b Binder) bind_convertion(typ symbols.TypeSymbol, expr ast.Expr) BoundExpr {
	bound_expr := b.bind_expr(expr)
	return b.bind_convertion_diag(expr.pos, bound_expr, typ)
}

pub fn (mut b Binder) bind_call_expr(expr ast.CallExpr) BoundExpr {
	func_name := expr.ident.lit
	// handle convertions as special functions
	if expr.params.len() == 1 {
		typ := lookup_type(func_name)
		if typ != symbols.none_symbol {
			return b.bind_convertion(typ, (expr.params.at(0) as ast.Expr))
		}
	}

	mut args := []BoundExpr{}

	for i := 0; i < expr.params.len(); i++ {
		param_expr := expr.params.at(i) as ast.Expr
		arg_expr := b.bind_expr(param_expr)

		if arg_expr.typ == symbols.error_symbol {
			return new_bound_error_expr()
		}
		args << arg_expr
	}

	func := b.scope.lookup_fn(func_name) or {
		b.log.error_undefined_function(func_name, expr.ident.pos)
		return new_bound_error_expr()
	}

	if expr.params.len() != func.params.len {
		b.log.error_wrong_argument_count(func_name, func.params.len, expr.pos)
		return new_bound_error_expr()
	}

	for i := 0; i < expr.params.len(); i++ {
		bound_arg := args[i]
		param := func.params[i]
		if bound_arg.typ == symbols.error_symbol {
			return new_bound_error_expr()
		}
		if bound_arg.typ != param.typ {
			b.log.error_wrong_argument_type(param.name, param.typ.name, bound_arg.typ.name,
				expr.params.at(i).pos)
			return new_bound_error_expr()
		}
	}

	return new_bound_call_expr(func, args)
}

pub fn (mut b Binder) bind_range_expr(range_expr ast.RangeExpr) BoundExpr {
	from_expr := b.bind_expr(range_expr.from)
	to_expr := b.bind_expr(range_expr.to)

	if from_expr.typ != to_expr.typ {
		b.log.error_expected_same_type_in_range_expr(from_expr.typ.name, range_expr.to.pos)
	}
	return new_range_expr(from_expr, to_expr)
}

fn bind_block_type(block BoundBlockStmt) ?symbols.TypeSymbol {
	last_block_node := block.bound_stmts.last()
	if last_block_node is BoundExprStmt {
		return last_block_node.bound_expr.typ
	}
	return none
}

pub fn (mut b Binder) bind_if_expr(if_expr ast.IfExpr) BoundExpr {
	cond_expr := b.bind_expr(if_expr.cond_expr)

	then_stmt := if_expr.then_stmt as ast.BlockStmt
	else_stmt := if_expr.else_stmt as ast.BlockStmt
	if then_stmt.stmts.len == 0 {
		b.log.error_empty_block_not_allowed(then_stmt.pos)
		return new_bound_error_expr()
	}
	if else_stmt.stmts.len == 0 {
		b.log.error_empty_block_not_allowed(else_stmt.pos)
		return new_bound_error_expr()
	}

	bound_then_stmt := b.bind_block_stmt(then_stmt) as BoundBlockStmt
	bound_else_stmt := b.bind_block_stmt(else_stmt) as BoundBlockStmt

	// check that the last statment is expression
	then_stmt_typ := bind_block_type(bound_then_stmt) or {
		b.log.error_expected_block_end_with_expression(then_stmt.pos)
		return new_bound_error_expr()
	}
	else_stmt_typ := bind_block_type(bound_else_stmt) or {
		b.log.error_expected_block_end_with_expression(else_stmt.pos)
		return new_bound_error_expr()
	}
	if then_stmt_typ == symbols.error_symbol || else_stmt_typ == symbols.error_symbol {
		return new_bound_error_expr()
	}
	if then_stmt_typ != else_stmt_typ {
		b.log.error_return_type_differ_expect_type(then_stmt_typ.name, else_stmt_typ.name,
			else_stmt.pos)
		return new_bound_error_expr()
	}

	conv_expre := b.bind_convertion_diag(if_expr.cond_expr.pos, cond_expr, symbols.bool_symbol)
	return new_if_else_expr(conv_expre, bound_then_stmt, bound_else_stmt)
}

pub fn (mut b Binder) bind_type(typ ast.TypeNode) symbols.TypeSymbol {
	bound_typ := lookup_type(typ.ident.lit)
	if bound_typ == symbols.none_symbol {
		b.log.error_undefined_type(typ.ident.lit, typ.pos)
	}
	return bound_typ
}

pub fn (mut b Binder) bind_var_decl_stmt(syntax ast.VarDeclStmt) BoundStmt {
	bound_expr := b.bind_expr(syntax.expr)

	var := b.bind_variable(syntax.ident, bound_expr.typ, syntax.is_mut)

	return new_var_decl_stmt(var, bound_expr, syntax.is_mut)
}

fn (mut b Binder) bind_assign_expr(syntax ast.AssignExpr) BoundExpr {
	name := syntax.ident.lit

	bound_expr := b.bind_expr(syntax.expr)

	if bound_expr.typ == symbols.error_symbol {
		return bound_expr
	}
	// check is varable exist in scope
	mut var := b.scope.lookup_var(name) or {
		// var have to be declared with := to be able to set a value
		b.log.error_var_not_exists(name, syntax.ident.pos)
		return new_bound_error_expr()
	}

	if !var.is_mut() {
		// trying to assign a nom a mutable var
		b.log.error_assign_non_mutable_variable(name, syntax.eq_tok.pos)
		return new_bound_error_expr()
	}

	conv_expr := b.bind_convertion_diag(syntax.expr.pos, bound_expr, var.typ)

	return new_bound_assign_expr(var, conv_expr)
}

fn (mut b Binder) bind_para_expr(syntax ast.ParaExpr) BoundExpr {
	return b.bind_expr(syntax.expr)
}

fn (mut b Binder) bind_name_expr(syntax ast.NameExpr) BoundExpr {
	name := syntax.ident.lit
	if name.len == 0 {
		// the parser inserted the token so we already reported 
		// correct error so just return an error expression
		return new_bound_error_expr()
	}

	variable := b.scope.lookup_var(name) or {
		b.log.error_var_not_exists(name, syntax.ident.pos)
		return new_bound_error_expr()
	}
	return new_bound_variable_expr(variable)
}

fn (mut b Binder) bind_literal_expr(syntax ast.LiteralExpr) BoundExpr {
	val := syntax.val
	return new_bound_literal_expr(val)
}
