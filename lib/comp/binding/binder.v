// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.token
import lib.comp.util.source
import lib.comp.symbols
import lib.comp.binding.convertion

[heap]
pub struct Binder {
pub:
	is_script bool
pub mut:
	scope             &BoundScope = 0
	func              symbols.FunctionSymbol
	log               &source.Diagnostics // errors when parsing
	mod               string
	is_loop           bool
	mod_ok_to_define  bool = true // if true it is ok to define a module
	current_is_global bool // if current statement is global statement
	allow_expr        bool // always allow expressions in blocks
	current_is_index  bool // to know if currectly bound expression is index expr
}

pub fn new_binder(is_script bool, parent &BoundScope, func symbols.FunctionSymbol) &Binder {
	mut scope := new_bound_scope(parent)
	new_binder := &Binder{
		scope: scope
		log: source.new_diagonistics()
		func: func
		is_script: is_script
	}
	for param in func.params {
		scope.try_declare_var(param)
	}
	return new_binder
}

pub fn bind_program(is_test bool, is_script bool, previous &BoundProgram, global_scope &BoundGlobalScope) &BoundProgram {
	parent_scope := create_parent_scope(global_scope)
	mut func_bodies := map[string]BoundBlockStmt{}

	mut log := source.new_diagonistics()
	for func in global_scope.funcs {
		mut binder := new_binder(is_script, parent_scope, func)
		fn_decl := binder.scope.lookup_fn_decl(func.unique_name()) or {
			panic('unexpected missing fn_decl in scope ($func.unique_name())')
		}
		if !fn_decl.is_c_decl {
			if func.receiver.is_empty == false {
				if !binder.scope.try_declare_var(func.receiver) {
					panic('unexpected, receiver should always be first variable declared')
				}
			}
			body := binder.bind_stmt(fn_decl.block)
			if func.typ.kind != .void_symbol && !all_path_return_in_body(body as BoundBlockStmt) {
				binder.log.error_all_paths_must_return(fn_decl.name_expr.name_tok.text_location())
			}
			func_bodies[func.id] = body as BoundBlockStmt
			log.all << binder.log.all
		}
	}

	valid_statements := global_scope.stmts.filter(it.kind != .comment_stmt)
	if global_scope.main_func != symbols.undefined_fn && valid_statements.len > 0 {
		body := new_bound_block_stmt(valid_statements)
		func_bodies[global_scope.main_func.id] = body
	} else if global_scope.script_func != symbols.undefined_fn {
		if valid_statements.len > 0 {
			mut stmts := []BoundStmt{cap: valid_statements.len + 1}
			last_statement := valid_statements.last()
			if last_statement.kind != .return_stmt {
				if last_statement.kind == .expr_stmt
					&& (last_statement as BoundExprStmt).expr.typ.kind != .void_symbol {
					for i, stmt in valid_statements {
						if i == valid_statements.len - 1 {
							// last statement
							stmts << new_bound_return_with_expr_stmt((stmt as BoundExprStmt).expr)
						} else {
							stmts << stmt
						}
					}
				} else {
					none_return := new_bound_literal_expr(symbols.None{})
					stmts << valid_statements
					stmts << new_bound_return_with_expr_stmt(none_return)
				}
			} else {
				stmts << valid_statements
			}
			body := new_bound_block_stmt(stmts)
			func_bodies[global_scope.script_func.id] = body
		} else {
			none_return := new_bound_literal_expr(symbols.None{})
			mut stmts := []BoundStmt{cap: 1}
			stmts << new_bound_return_with_expr_stmt(none_return)
			body := new_bound_block_stmt(stmts)
			func_bodies[global_scope.script_func.id] = body
		}
	}

	// check if program is not test and missing main or script function
	if is_test == false && is_script == false {
		if global_scope.main_func.id !in func_bodies {
			log.error_missing_main_func()
		}
	}

	bound_program := new_bound_program(previous, log, global_scope.main_func, global_scope.script_func,
		func_bodies, global_scope.funcs, global_scope.types)
	return bound_program
}

pub fn bind_global_scope(is_script bool, previous &BoundGlobalScope, syntax_trees []&ast.SyntaxTree) &BoundGlobalScope {
	parent_scope := create_parent_scope(previous)
	mut binder := new_binder(is_script, parent_scope, symbols.undefined_fn)

	// bind the built-in types
	for typ in symbols.builtin_types {
		binder.scope.try_declare_type(typ)
	}

	// first bind the types
	for syntax_tree in syntax_trees {
		for node in syntax_tree.root.members {
			if node is ast.StructDeclNode {
				binder.bind_struct_decl(node)
			}
		}
	}
	// then bind the type members
	for syntax_tree in syntax_trees {
		for node in syntax_tree.root.members {
			if node is ast.StructDeclNode {
				binder.bind_struct_member(node)
			}
		}
	}

	// first bind the functions
	for syntax_tree in syntax_trees {
		for node in syntax_tree.root.members {
			if node is ast.FnDeclNode {
				binder.bind_fn_decl(node)
			}
		}
	}

	// then bind the global statements
	mut glob_stmts := []BoundStmt{}
	for syntax_tree in syntax_trees {
		for node in syntax_tree.root.members {
			if node is ast.GlobStmt {
				s := binder.bind_global_stmt(node.stmt)
				glob_stmts << s
			}
		}
	}
	mut main_func := symbols.undefined_fn
	mut script_func := symbols.undefined_fn

	if is_script {
		if glob_stmts.len > 0 {
			script_func = symbols.new_function_symbol('\$eval', []symbols.ParamSymbol{},
				symbols.any_symbol)
		}
	} else {
		// global statements can only occur at most in one syntax tree
		// if main function exists, global statements cannot
		main_func_filter_result := binder.scope.funcs().filter(it.name == 'main')

		// get the declared main function or return empty declaration
		main_func = if main_func_filter_result.len == 1 {
			main_func_filter_result[0]
		} else {
			symbols.undefined_fn
		}

		// if we have a main function declared, check the signature
		if main_func != symbols.undefined_fn {
			if main_func.typ.kind != .void_symbol || main_func.params.len > 0 {
				func_decl := binder.scope.lookup_fn_decl(main_func.name) or {
					panic('unexpected error, function declaration not found')
				}
				binder.log.error_main_function_must_have_correct_signature(func_decl.name_expr.name_tok.text_location())
			}
		}

		// get the first global statement in each syntax tree
		mut first_global_statements := []ast.GlobStmt{cap: syntax_trees.len}
		for syntax_tree in syntax_trees {
			if syntax_tree.root.members.len > 0 {
				global_stmts := syntax_tree.root.members.filter(it is ast.GlobStmt
					&& (it as ast.GlobStmt).stmt.kind != .comment_stmt)
				if global_stmts.len > 0 {
					first_global_stmt := global_stmts[0]
					first_global_statements << first_global_stmt as ast.GlobStmt
				}
			}
		}
		if first_global_statements.len > 0 {
			// we have global statements
			if first_global_statements.len > 1 {
				// has mulitple global statements in several syntax trees
				for global_stmt in first_global_statements {
					binder.log.error_global_stmts_can_only_be_defined_in_one_file(global_stmt.text_location())
				}
			} else if main_func != symbols.undefined_fn {
				// has mixed main and glob stmts
				for global_stmt in first_global_statements {
					binder.log.error_cannot_mix_global_statements_and_main_function(global_stmt.text_location())
				}
				func_decl := binder.scope.lookup_fn_decl(main_func.name) or {
					panic('unexpected error, function declaration not found')
				}
				binder.log.error_cannot_mix_global_statements_and_main_function(func_decl.name_expr.name_tok.text_location())
			} else {
				main_func = symbols.new_function_symbol('main', []symbols.ParamSymbol{},
					symbols.void_symbol)
			}
		}
	}

	fns := binder.scope.funcs()
	fn_decls := binder.scope.func_decls()
	vars := binder.scope.vars()
	mut diagnostics := binder.log.all
	if previous != 0 && previous.log.all.len > 0 {
		diagnostics.prepend(previous.log.all)
	}

	return new_bound_global_scope(previous, binder.log, script_func, main_func, fns, fn_decls,
		vars, glob_stmts, binder.scope.types)
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
		for _, typ in prev.types {
			scope.try_declare_type(typ)
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

pub fn (mut b Binder) bind_global_stmt(stmt ast.Stmt) BoundStmt {
	b.current_is_global = true
	glob_stmt := b.bind_stmt(stmt)
	b.current_is_global = false
	return glob_stmt
}

pub fn (mut b Binder) bind_stmt(stmt ast.Stmt) BoundStmt {
	result := b.bind_stmt_internal(stmt)

	if !b.allow_expr && (!b.is_script || !b.current_is_global) {
		if result is BoundExprStmt {
			allowed_expression := result.expr.kind == .call_expr || result.expr.kind == .if_expr
				|| result.expr.kind == .assign_expr || result.expr.kind == .error_expr

			if !allowed_expression {
				b.log.error_invalid_expression_statement(stmt.text_location())
			}
		}
	}
	return result
}

pub fn (mut b Binder) bind_stmt_internal(stmt ast.Stmt) BoundStmt {
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
		.continue_stmt { return b.bind_continue_stmt(stmt as ast.ContinueStmt) }
		.break_stmt { return b.bind_break_stmt(stmt as ast.BreakStmt) }
		.return_stmt { return b.bind_return_stmt(stmt as ast.ReturnStmt) }
		.comment_stmt { return new_bound_comment_stmt((stmt as ast.CommentStmt).comment_tok) }
		.module_stmt { return b.bind_module_stmt(stmt as ast.ModuleStmt) }
		.assert_stmt { return b.bind_assert_stmt(stmt as ast.AssertStmt) }
		else { panic('unexpected stmt kind: $stmt.kind') }
	}
}

pub fn (mut b Binder) bind_assert_stmt(assert_stmt ast.AssertStmt) BoundStmt {
	expr := b.bind_expr(assert_stmt.expr)
	if expr.kind == .error_expr {
		// We got an error allready
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	converted_expr := b.bind_convertion_diag(assert_stmt.expr.text_location(), expr, symbols.bool_symbol)
	// get the code for the assert
	assert_code := assert_stmt.expr.str()
	return new_bound_assert_stmt(assert_stmt.text_location(), converted_expr, assert_code)
}

pub fn (mut b Binder) bind_module_stmt(module_stmt ast.ModuleStmt) BoundStmt {
	if b.mod.len > 0 {
		b.log.error_module_can_only_be_defined_once(module_stmt.text_location())
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	if !b.mod_ok_to_define {
		b.log.error_module_can_only_be_defined_as_first_statement(module_stmt.text_location())
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	b.mod = module_stmt.name_tok.lit
	return new_bound_module_stmt(module_stmt.name_tok)
}

pub fn (mut b Binder) bind_struct_member(struct_decl ast.StructDeclNode) {
	// binds the members after all structs has been declared
	struct_name := struct_decl.name_tok.lit

	symbol := b.scope.lookup_type(struct_name) or {
		panic('unexpected: struct symbol table missing member $struct_name')
	}
	mut struct_symbol := symbol as symbols.StructTypeSymbol
	for member in struct_decl.members {
		member_name := member.name_tok.lit
		member_type := b.lookup_type(member.type_name.lit)
		member_symbol := symbols.new_struct_type_member(member_name, member_type)
		struct_symbol.members << member_symbol
		// Todo:, check the casing of names and types
	}
	if !b.scope.try_replace_type(struct_symbol) {
		panic('unexpected, fail to replace type')
	}
}

pub fn (mut b Binder) bind_struct_decl(struct_decl ast.StructDeclNode) {
	struct_symbol := symbols.new_struct_symbol(struct_decl.name_tok.lit, false)
	if !b.scope.try_declare_type(struct_symbol) {
		b.log.error_struct_allready_declared(struct_decl.name_tok.lit, struct_decl.name_tok.text_location())
	}
}

pub fn (mut b Binder) bind_fn_decl(fn_decl ast.FnDeclNode) {
	mut params := []symbols.ParamSymbol{}
	mut seen_param_names := []string{}
	for i := 0; i < fn_decl.params.len(); i++ {
		param_node := fn_decl.params.at(i) as ast.ParamNode
		name := param_node.name_tok.lit
		param_typ := b.bind_type(param_node.typ)
		if param_node.is_variadic && i != fn_decl.params.len() - 1 {
			b.log.error_variadic_parameters_can_only_be_last(name, param_node.name_tok.text_location())
		}
		if name in seen_param_names {
			b.log.error_param_allready_declared(name, param_node.name_tok.text_location())
		} else {
			param_symbol := symbols.new_param_symbol(name, param_typ, param_node.is_mut,
				param_node.is_variadic, param_node.is_ref)
			params << param_symbol
			seen_param_names << name
		}
	}
	typ := if !fn_decl.typ_node.is_void {
		b.bind_type(fn_decl.typ_node)
	} else {
		symbols.TypeSymbol(symbols.void_symbol)
	}

	if fn_decl.receiver_node.is_empty {
		func := symbols.new_function_symbol_from_decl(fn_decl.text_location(), symbols.empty_var_symbol,
			fn_decl.name_expr.name_tok.lit, params, typ, fn_decl.is_pub, fn_decl.is_c_decl)
		// TODO: refactor this. Due to V bug the func could not
		//		 include the decl
		if !b.scope.try_declare_fn(func, fn_decl) {
			b.log.error_function_allready_declared(fn_decl.name_expr.name_tok.lit, fn_decl.name_expr.name_tok.text_location())
		}
		return
	}
	receiver_typ := b.bind_type(fn_decl.receiver_node.typ_node)
	receiver_var := symbols.new_local_variable_symbol(fn_decl.receiver_node.name_tok.lit,
		receiver_typ, fn_decl.receiver_node.is_mut)
	func := symbols.new_function_symbol_from_decl(fn_decl.text_location(), receiver_var,
		fn_decl.name_expr.name_tok.lit, params, typ, fn_decl.is_pub, fn_decl.is_c_decl)
	// TODO: refactor this. Due to V bug the func could not
	//		 include the decl
	if !b.scope.try_declare_fn(func, fn_decl) {
		b.log.error_function_allready_declared(fn_decl.name_expr.name_tok.lit, fn_decl.name_expr.name_tok.text_location())
	}
}

pub fn (mut b Binder) bind_return_stmt(return_stmt ast.ReturnStmt) BoundStmt {
	mut expr := if return_stmt.has_expr {
		b.bind_expr(return_stmt.expr)
	} else {
		new_bound_emtpy_expr()
	}
	if b.func == symbols.undefined_fn {
		if b.is_script {
			// ignore cause we allow both return with and without
			// values in script mode
			if !return_stmt.has_expr {
				expr = new_bound_literal_expr('')
			}
		} else if return_stmt.has_expr {
			// main does not support return values
			b.log.error_invalid_return(return_stmt.return_key.text_location())
		}
		return new_bound_return_with_expr_stmt(expr)
	} else {
		// is_void_return_typ := b.func.typ is symbols.BuiltInTypeSymbol && b.func.typ as symbols.BuiltInTypeSymbol
		if return_stmt.has_expr {
			if b.func.typ.kind == .void_symbol {
				// it is a subroutine
				b.log.error_invalid_return_expr(b.func.name, return_stmt.expr.text_location())
			} else {
				expr = b.bind_convertion_diag(return_stmt.expr.text_location(), expr,
					b.func.typ)
			}
			return new_bound_return_with_expr_stmt(expr)
		} else {
			if b.func.typ.kind != .void_symbol {
				b.log.error_expected_return_value(b.func.typ.name, return_stmt.return_key.text_location())
			}
			return new_bound_return_stmt()
		}
	}
}

pub fn (mut b Binder) bind_continue_stmt(continue_stmt ast.ContinueStmt) BoundStmt {
	if b.is_loop == false {
		b.log.error_keyword_are_only_allowed_inside_a_loop('continue', continue_stmt.text_location())
	}
	return new_bound_continue_stmt()
}

pub fn (mut b Binder) bind_break_stmt(break_stmt ast.BreakStmt) BoundStmt {
	if b.is_loop == false {
		b.log.error_keyword_are_only_allowed_inside_a_loop('break', break_stmt.text_location())
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
		b.log.error_name_already_defined(name, ident.text_location())
	}
	return variable
}

pub fn (mut b Binder) bind_for_range_stmt(for_range_stmt ast.ForRangeStmt) BoundStmt {
	range_expr := b.bind_expr(for_range_stmt.range_expr)
	b.scope = new_bound_scope(b.scope)

	ident := b.bind_variable(for_range_stmt.name_tok, range_expr.typ, false)
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
		ast.IndexExpr { return b.bind_index_expr(expr) }
		ast.ArrayInitExpr { return b.bind_array_init_expr(expr) }
		ast.StructInitExpr { return b.bind_struct_init_expr(expr) }
		ast.AssignExpr { return b.bind_assign_expr(expr) }
		ast.IfExpr { return b.bind_if_expr(expr) }
		ast.RangeExpr { return b.bind_range_expr(expr) }
		else { panic('unexpected bound expression $expr') }
	}
}

fn (mut b Binder) lookup_type(name string) symbols.TypeSymbol {
	return b.scope.lookup_type(name) or { symbols.none_symbol }
}

pub fn (mut b Binder) bind_convertion_diag(diag_loc source.TextLocation, expr BoundExpr, typ symbols.TypeSymbol) BoundExpr {
	return b.bind_convertion_diag_explicit(diag_loc, expr, typ, false)
}

pub fn (mut b Binder) bind_convertion_diag_explicit(diag_loc source.TextLocation, expr BoundExpr, typ symbols.TypeSymbol, allow_explicit bool) BoundExpr {
	conv := convertion.classify(expr.typ, typ)
	if !conv.exists {
		// convertion does not exist
		if expr.typ.kind != .error_symbol && typ.kind != .error_symbol {
			b.log.error_cannot_convert_type(expr.typ.str(), typ.str(), diag_loc)
		}
		return new_bound_error_expr()
	}
	if !allow_explicit && conv.is_explicit {
		b.log.error_cannot_convert_implicitly(expr.typ.str(), typ.str(), diag_loc)
	}
	if conv.is_identity {
		if typ.is_ref && !expr.typ.is_ref {
			// b.log.error_convertion_differ_by_reference(typ.is_ref, expr.str(), diag_loc)
			return expr.to_ref_type()
		}
		return expr
	}
	return new_bound_conv_expr(typ, expr)
}

pub fn (mut b Binder) bind_convertion(typ symbols.TypeSymbol, expr ast.Expr) BoundExpr {
	bound_expr := b.bind_expr(expr)
	return b.bind_convertion_diag(expr.text_location(), bound_expr, typ)
}

pub fn (mut b Binder) bind_convertion_explicit(typ symbols.TypeSymbol, expr ast.Expr, is_explicit bool) BoundExpr {
	bound_expr := b.bind_expr(expr)
	return b.bind_convertion_diag_explicit(expr.text_location(), bound_expr, typ, is_explicit)
}

pub fn (mut b Binder) bind_call_expr(expr ast.CallExpr) BoundExpr {
	is_c_call := expr.name_expr.names[0].lit == 'C'
	func_name := expr.name_expr.names[expr.name_expr.names.len - 1].lit // expr.name_expr.name_tok.lit
	// handle convertions as special functions
	if expr.name_expr.names.len == 1 && expr.params.len == 1 {
		typ := b.lookup_type(func_name)
		if typ.kind != .none_symbol {
			is_ref := expr.name_expr.ref_tok.kind != .void
			real_typ := if is_ref { typ.to_ref_type() } else { typ }
			return b.bind_convertion_explicit(real_typ, expr.params[0].expr, true)
		}
	}

	mut args := []BoundExpr{cap: expr.params.len}

	for param in expr.params {
		arg_expr := b.bind_expr(param.expr)

		if arg_expr.typ.kind == .error_symbol {
			return new_bound_error_expr()
		}
		args << arg_expr
	}
	mut receiver_var := symbols.empty_var_symbol
	// mut receiver_typ := symbols.TypeSymbol(symbols.undefined_symbol)

	if expr.name_expr.names.len > 1 && expr.name_expr.names[0].lit != 'C' {
		// the function is on a variable
		// todo: when modules is supported, lookup here
		base_ident := expr.name_expr.names[0]
		base_name := base_ident.lit
		// check is variable exist in scope
		var := b.scope.lookup_var(base_name) or {
			b.log.error_var_not_exists(base_name, base_ident.text_location())
			return new_bound_error_expr()
		}
		receiver_var = var as symbols.LocalVariableSymbol
	}
	mut func := symbols.new_emtpy_function_symbol()
	if receiver_var.is_empty {
		lookup_name := if !is_c_call { func_name } else { expr.name_expr.name_tok.lit }
		func = b.scope.lookup_fn(lookup_name) or {
			b.log.error_undefined_function(lookup_name, expr.name_expr.name_tok.text_location())
			return new_bound_error_expr()
		}
	} else {
		func = b.scope.lookup_type_fn(func_name, receiver_var.typ) or {
			b.log.error_undefined_function(func_name, expr.name_expr.name_tok.text_location())
			return new_bound_error_expr()
		}
	}

	if expr.params.len != func.params.len {
		b.log.error_wrong_argument_count(func_name, func.params.len, expr.text_location())
		return new_bound_error_expr()
	}

	for i := 0; i < expr.params.len; i++ {
		arg_location := expr.params[i].expr.text_location()
		bound_arg := args[i]
		param := func.params[i]
		if param.is_mut {
			if bound_arg.kind != .variable_expr {
				b.log.error_only_variables_can_be_input_to_mutable_parameters(arg_location)
				return new_bound_error_expr()
			}
			if expr.params[i].is_mut == false {
				b.log.error_provide_mut_keyword_for_mutable_parameters(arg_location)
				return new_bound_error_expr()
			}
		}
		conv_expr := b.bind_convertion_diag(arg_location, bound_arg, param.typ)
		args[i] = conv_expr
	}
	return new_bound_call_expr(func, receiver_var, args, is_c_call)
}

pub fn (mut b Binder) bind_range_expr(range_expr ast.RangeExpr) BoundExpr {
	from_expr := b.bind_expr(range_expr.from_expr)
	to_expr := b.bind_expr(range_expr.to_expr)

	if from_expr.typ != to_expr.typ {
		b.log.error_expected_same_type_in_range_expr(from_expr.typ.name, range_expr.to_expr.text_location())
	}
	return new_range_expr(from_expr, to_expr)
}

fn bind_block_type(block BoundBlockStmt) ?symbols.TypeSymbol {
	last_block_node := block.stmts.last()
	if last_block_node is BoundExprStmt {
		return last_block_node.expr.typ
	}
	return none
}

pub fn (mut b Binder) bind_if_expr(if_expr ast.IfExpr) BoundExpr {
	cond_expr := b.bind_expr_type(if_expr.cond_expr, symbols.bool_symbol)

	then_stmt := if_expr.then_stmt as ast.BlockStmt
	else_stmt := if_expr.else_stmt as ast.BlockStmt
	if then_stmt.stmts.len == 0 {
		b.log.error_empty_block_not_allowed(then_stmt.text_location())
		return new_bound_error_expr()
	}
	if else_stmt.stmts.len == 0 {
		b.log.error_empty_block_not_allowed(else_stmt.text_location())
		return new_bound_error_expr()
	}
	b.allow_expr = true
	bound_then_stmt := b.bind_block_stmt(then_stmt) as BoundBlockStmt
	bound_else_stmt := b.bind_block_stmt(else_stmt) as BoundBlockStmt
	b.allow_expr = false

	// check that the last statment is expression
	then_stmt_typ := bind_block_type(bound_then_stmt) or {
		b.log.error_expected_block_end_with_expression(then_stmt.text_location())
		return new_bound_error_expr()
	}
	else_stmt_typ := bind_block_type(bound_else_stmt) or {
		b.log.error_expected_block_end_with_expression(else_stmt.text_location())
		return new_bound_error_expr()
	}
	if then_stmt_typ.kind == .error_symbol || else_stmt_typ.kind == .error_symbol {
		return new_bound_error_expr()
	}
	if then_stmt_typ != else_stmt_typ {
		b.log.error_return_type_differ_expect_type(then_stmt_typ.name, else_stmt_typ.name,
			else_stmt.text_location())
		return new_bound_error_expr()
	}

	conv_expre := b.bind_convertion_diag(if_expr.cond_expr.text_location(), cond_expr,
		symbols.bool_symbol)
	return new_if_else_expr(conv_expre, bound_then_stmt, bound_else_stmt)
}

pub fn (mut b Binder) bind_type(typ ast.TypeNode) symbols.TypeSymbol {
	bound_typ := b.lookup_type(typ.name_tok.lit)
	if bound_typ.kind == .none_symbol {
		b.log.error_undefined_type(typ.name_tok.lit, typ.text_location())
	}
	if typ.is_ref {
		return bound_typ.to_ref_type()
	}
	return bound_typ
}

pub fn (mut b Binder) bind_var_decl_stmt(syntax ast.VarDeclStmt) BoundStmt {
	if syntax.ident.names.len > 1 {
		// Todo: handle modules later
		// We are not allowed to declare variables like var.x := 1
		b.log.error_structs_fields_declared_on_init(syntax.ident.names[1].text_location())
		return new_bound_expr_stmt(new_bound_error_expr())
	}
	expr := b.bind_expr(syntax.expr)
	expr_typ := expr.typ
	if expr_typ.kind == .array_symbol {
		arr_typ := expr_typ as symbols.ArrayTypeSymbol
		if arr_typ.is_val_array && arr_typ.is_fixed && syntax.is_mut {
			b.log.error_a_fixed_value_array_cannot_be_muted(syntax.mut_tok.text_location())
		}
	}

	var := b.bind_variable(syntax.ident.name_tok, expr.typ, syntax.is_mut)
	return new_var_decl_stmt(var, expr, syntax.is_mut)
}

fn (mut b Binder) bind_assign_expr(syntax ast.AssignExpr) BoundExpr {
	expr := b.bind_expr(syntax.expr)

	if expr.typ.kind == .error_symbol {
		return expr
	}

	// todo: when modules is supported, lookup here
	// then it can be a global constant
	base_ident := syntax.name_expr.names[0]
	base_name := base_ident.lit
	// check is variable exist in scope
	base_var := b.scope.lookup_var(base_name) or {
		b.log.error_var_not_exists(base_name, base_ident.text_location())
		return new_bound_error_expr()
	}

	if !base_var.is_mut() {
		// trying to assign a nom a mutable var
		b.log.error_assign_non_mutable_variable(base_name, syntax.eq_tok.text_location())
		return new_bound_error_expr()
	}

	if syntax.name_expr.names.len == 1 {
		// non struct, just return the bound variable
		conv_expr := b.bind_convertion_diag(syntax.expr.text_location(), expr, base_var.typ)
		return new_bound_assign_expr(base_var, conv_expr)
	}

	mut current_typ := base_var.typ
	for i := 1; i < syntax.name_expr.names.len; i++ {
		name_tok := syntax.name_expr.names[i]
		member_name := name_tok.lit
		member_typ := current_typ.lookup_member_type(member_name)
		if member_typ.kind == .error_symbol {
			b.log.error_member_not_exists(member_name, name_tok.text_location())
			return new_bound_error_expr()
		}
		// Todo: check mutability of fields
		current_typ = member_typ
	}

	conv_expr := b.bind_convertion_diag(syntax.expr.text_location(), expr, current_typ)

	return new_bound_assign_with_names_expr(base_var, syntax.name_expr.names, conv_expr)
}

fn (mut b Binder) bind_para_expr(syntax ast.ParaExpr) BoundExpr {
	return b.bind_expr(syntax.expr)
}

fn (mut b Binder) bind_index_expr(syntax ast.IndexExpr) BoundExpr {
	left_expr := b.bind_expr(syntax.left_expr)
	index_expr := b.bind_expr(syntax.index_expr)

	if index_expr.kind == .error_expr {
		return index_expr
	}
	if left_expr.kind != .variable_expr {
		b.log.error_expression_does_not_support_indexing(syntax.left_expr.text_location())
		return new_bound_error_expr()
	}
	// Todo: when handling maps this can be one too
	if left_expr.typ.kind != .array_symbol {
		b.log.error_variable_type_is_not_an_array(syntax.left_expr.text_location())
		return new_bound_error_expr()
	}
	index_typ := index_expr.typ
	if index_typ is symbols.BuiltInTypeSymbol {
		if index_typ == symbols.int_symbol {
			return new_bound_index_expr(left_expr, index_expr)
		}
	}
	b.log.error_expression_does_not_support_indexing(syntax.left_expr.text_location())
	return new_bound_error_expr()
}

fn (mut b Binder) bind_array_init_expr(syntax ast.ArrayInitExpr) BoundExpr {
	if syntax.is_val_array && syntax.is_fixed {
		mut array_elements := []BoundExpr{cap: syntax.exprs.len}
		mut first_elem_typ := symbols.TypeSymbol(symbols.void_symbol)
		mut first_elem_is_ref := false
		for i, expr in syntax.exprs {
			bound_expr := b.bind_expr(expr)
			if bound_expr.kind == .error_expr {
				return bound_expr
			}
			if i > 0 {
				conv_expr := b.bind_convertion_diag(expr.text_location(), bound_expr,
					first_elem_typ)
				if conv_expr.kind == .error_expr {
					return conv_expr
				}
				if first_elem_is_ref != bound_expr.typ.is_ref {
					b.log.error_elements_in_array_needs_to_be_of_same_type(first_elem_typ.name,
						first_elem_is_ref, expr.text_location())
				}
				array_elements << conv_expr
			} else {
				first_elem_typ = bound_expr.typ
				first_elem_is_ref = bound_expr.typ.is_ref
				array_elements << bound_expr
			}
		}
		array_typ := symbols.new_fixed_val_array_symbol(first_elem_typ, array_elements.len,
			first_elem_is_ref)
		return new_bound_val_array_init_expr(array_typ, array_elements)
	}
	panic('not supported array yet')
}

fn (mut b Binder) bind_struct_init_expr(syntax ast.StructInitExpr) BoundExpr {
	typ := b.lookup_type(syntax.name_expr.name_tok.lit)
	struct_typ := typ as symbols.StructTypeSymbol

	mut members := []BoundStructInitMember{}
	for struct_member in struct_typ.members {
		struct_member_typ := struct_member.typ
		members_result := syntax.members.filter(it.ident.lit == struct_member.ident)
		mut bound_expr := new_empty_expr()
		if members_result.len == 0 {
			bound_expr = b.bind_default_value_expr(struct_member_typ)
		} else {
			bound_expr = b.bind_expr(members_result[0].expr)
			bound_expr = b.bind_convertion_diag(members_result[0].expr.text_location(),
				bound_expr, struct_member_typ)
		}
		bound_member := new_bound_struct_init_member(struct_member.ident, bound_expr)
		members << bound_member
	}

	return new_bound_struct_init_expr(typ, members)
}

fn (mut b Binder) bind_default_value_expr(typ symbols.TypeSymbol) BoundExpr {
	match typ {
		symbols.StructTypeSymbol {
			return b.bind_struct_init_expr(ast.new_struct_init_no_members_expr(typ.name))
		}
		symbols.ErrorTypeSymbol {
			return new_bound_error_expr()
		}
		symbols.AnyTypeSymbol {
			panic('unexpected any type')
		}
		symbols.ArrayTypeSymbol {
			panic('unexpected array type')
		}
		symbols.VoidTypeSymbol {
			panic('unexpected void type')
		}
		symbols.BuiltInTypeSymbol {
			match typ.kind {
				.string_symbol {
					return new_bound_literal_expr('') // Default to empty string
				}
				.int_symbol {
					return new_bound_literal_expr(0) // Default to 0
				}
				.char_symbol {
					return new_bound_literal_expr(char(0)) // Default to 0
				}
				.byte_symbol {
					return new_bound_literal_expr(byte(0)) // Default to 0
				}
				.i64_symbol {
					return new_bound_literal_expr(i64(0)) // Default to 0
				}
				.bool_symbol {
					return new_bound_literal_expr(false) // Default to false
				}
				else {
					panic('unexpected literal type $typ.name')
				}
			}
		}
	}
	panic('unexpected not found match for type $typ')
}

fn (mut b Binder) bind_name_expr(syntax ast.NameExpr) BoundExpr {
	if syntax.names.len == 0 {
		// the parser inserted the token so we already reported
		// correct error so just return an error expression
		return new_bound_error_expr()
	}
	// todo: when modules is supported, lookup here
	// then it can be a global constant
	base_ident := syntax.names[0]
	base_name := base_ident.lit
	base_var := b.scope.lookup_var(base_name) or {
		b.log.error_var_not_exists(base_name, base_ident.text_location())
		return new_bound_error_expr()
	}
	if syntax.names.len == 1 {
		// non struct, just return the bound variable
		return new_bound_variable_expr(base_var, base_var.typ)
	}
	mut current_typ := base_var.typ
	for i := 1; i < syntax.names.len; i++ {
		name_tok := syntax.names[i]
		member_name := name_tok.lit
		member_typ := current_typ.lookup_member_type(member_name)
		if member_typ.kind == .error_symbol {
			b.log.error_member_not_exists(member_name, name_tok.text_location())
			return new_bound_error_expr()
		}
		current_typ = member_typ
	}

	return new_bound_variable_with_names_expr(base_var, syntax.names, current_typ)
}

fn (mut b Binder) bind_literal_expr(syntax ast.LiteralExpr) BoundExpr {
	val := syntax.val
	return new_bound_literal_expr(val)
}
