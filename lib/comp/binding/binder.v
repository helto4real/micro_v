// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.token
import lib.comp.util
import lib.comp.symbols
import lib.comp.binding.convertion

[heap]
pub struct Binder {
pub mut:
	scope &BoundScope
	log   &util.Diagnostics // errors when parsing
}

pub fn new_binder(parent &BoundScope) &Binder {
	return &Binder{
		scope: new_bound_scope(parent)
		log: util.new_diagonistics()
	}
}

pub fn bind_global_scope(previous &BoundGlobalScope, comp_node &ast.CompNode) &BoundGlobalScope {
	parent_scope := create_parent_scope(previous)
	mut binder := new_binder(parent_scope)
	stmt := binder.bind_stmt(comp_node.stmt)
	vars := binder.scope.vars()
	mut diagnostics := binder.log.all
	if previous != 0 && previous.log.all.len > 0 {
		diagnostics.prepend(previous.log.all)
	}
	return new_bound_global_scope(previous, binder.log, vars, stmt)
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
		result.try_declare_fn(f)
	}
	return result
}

pub fn (mut b Binder) bind_stmt(stmt ast.Stmt) BoundStmt {
	match stmt {
		ast.BlockStmt { return b.bind_block_stmt(stmt) }
		ast.ExprStmt { return b.bind_expr_stmt(stmt) }
		ast.VarDeclStmt { return b.bind_var_decl_stmt(stmt) }
		ast.IfStmt { return b.bind_if_stmt(stmt) }
		ast.ForRangeStmt { return b.bind_for_range_stmt(stmt) }
		ast.ForStmt { return b.bind_for_stmt(stmt) }
	}
}

pub fn (mut b Binder) bind_for_stmt(for_stmt ast.ForStmt) BoundStmt {
	cond_expr := if for_stmt.has_cond {
		b.bind_expr_type(for_stmt.cond_expr, symbols.bool_symbol)
	} else {
		BoundExpr{}
	}

	body_stmt := b.bind_stmt(for_stmt.body_stmt)

	return new_for_stmt(cond_expr, body_stmt, for_stmt.has_cond)
}

pub fn (mut b Binder) bind_variable(ident token.Token, typ symbols.TypeSymbol, is_mut bool) &symbols.VariableSymbol {
	name := ident.lit
	variable := symbols.new_variable_symbol(name, typ, is_mut)

	if !b.scope.try_declare_var(variable) {
		b.log.error_name_already_defined(name, ident.pos)
	}
	return variable
}

pub fn (mut b Binder) bind_for_range_stmt(for_range_stmt ast.ForRangeStmt) BoundStmt {
	range_expr := b.bind_expr(for_range_stmt.range_expr)
	ident := b.bind_variable(for_range_stmt.ident, range_expr.typ(), false)
	body_stmt := b.bind_stmt(for_range_stmt.body_stmt)

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

pub fn (mut b Binder) bind_block_stmt(block_stmt ast.BlockStmt) BoundStmt {
	b.scope = new_bound_scope(b.scope)
	mut stmts := []BoundStmt{}
	for i, _ in block_stmt.stmts {
		stmts << b.bind_stmt(block_stmt.stmts[i])
	}
	b.scope = b.scope.parent
	return new_bound_block_stmt(stmts)
}

pub fn (mut b Binder) bind_expr_stmt(expr_stmt ast.ExprStmt) BoundStmt {
	expr := b.bind_expr(expr_stmt.expr)
	return new_bound_expr_stmt(expr)
}

pub fn (mut b Binder) bind_expr_type(expr ast.Expr, typ symbols.TypeSymbol) BoundExpr {
	bound_expr := b.bind_expr(expr)

	if typ != symbols.error_symbol && bound_expr.typ() != symbols.error_symbol
		&& typ != bound_expr.typ() {
		// We expect the condition to be a boolean expression
		b.log.error_expected_correct_type_expr(typ.name, bound_expr.typ().name, expr.pos())
	}
	return bound_expr
}

pub fn (mut b Binder) bind_expr(expr ast.Expr) BoundExpr {
	match expr {
		ast.LiteralExpr { return b.bind_literal_expr(expr) }
		ast.UnaryExpr { return b.bind_unary_expr(expr) }
		ast.BinaryExpr { return b.bind_binary_expr(expr) }
		ast.ParaExpr { return b.bind_para_expr(expr) }
		ast.NameExpr { return b.bind_name_expr(expr) }
		ast.AssignExpr { return b.bind_assign_expr(expr) }
		ast.IfExpr { return b.bind_if_expr(expr) }
		ast.RangeExpr { return b.bind_range_expr(expr) }
		ast.CallExpr { return b.bind_call_expr(expr) }
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

pub fn (mut b Binder) bind_convertion(typ symbols.TypeSymbol, expr ast.Expr) BoundExpr {
	bound_expr := b.bind_expr(expr)
	conv := convertion.classify(bound_expr.typ(), typ)

	if !conv.exists {
		// convertion does not exist
		b.log.error_cannot_convert_type(bound_expr.typ().str(), typ.str(), expr.pos())
		return new_bound_error_expr()
	}
	return new_bound_conv_expr(typ, bound_expr)
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
		args << arg_expr
	}

	func := b.scope.lookup_fn(func_name) or {
		b.log.error_undefinded_function(func_name, expr.ident.pos)
		return new_bound_error_expr()
	}

	if expr.params.len() != func.params.len {
		b.log.error_wrong_argument_count(func_name, func.params.len, expr.pos)
		return new_bound_error_expr()
	}

	for i := 0; i < expr.params.len(); i++ {
		bound_arg := args[i]
		param := func.params[i]

		if bound_arg.typ() != param.typ {
			b.log.error_wrong_argument_type(param.name, param.typ.name, bound_arg.typ().name,
				expr.pos)
			return new_bound_error_expr()
		}
	}

	return new_bound_call_expr(func, args)
}
pub fn (mut b Binder) bind_range_expr(range_expr ast.RangeExpr) BoundExpr {
	from_expr := b.bind_expr(range_expr.from)
	to_expr := b.bind_expr(range_expr.to)

	if from_expr.typ() != to_expr.typ() {
		b.log.error_expected_same_type_in_range_expr(from_expr.typ().name, range_expr.to.pos())
	}
	return new_range_expr(from_expr, to_expr)
}

pub fn (mut b Binder) bind_if_expr(if_expr ast.IfExpr) BoundExpr {
	cond_expr := b.bind_expr(if_expr.cond_expr)
	if cond_expr.typ() != symbols.int_symbol {
		// We expect the condition to be a boolean expression
		b.log.error_expected_bool_expr(if_expr.cond_expr.pos())
	}

	then_stmt := if_expr.then_stmt as ast.BlockStmt
	bound_then_stmt := b.bind_block_stmt(then_stmt)

	else_stmt := if_expr.else_stmt as ast.BlockStmt
	bound_else_stmt := b.bind_block_stmt(else_stmt)
	return new_if_else_expr(cond_expr, bound_then_stmt, bound_else_stmt)
}

pub fn (mut b Binder) bind_var_decl_stmt(syntax ast.VarDeclStmt) BoundStmt {
	bound_expr := b.bind_expr(syntax.expr)
	var := b.bind_variable(syntax.ident, bound_expr.typ(), syntax.is_mut)

	return new_var_decl_stmt(var, bound_expr, syntax.is_mut)
}

fn (mut b Binder) bind_assign_expr(syntax ast.AssignExpr) BoundExpr {
	name := syntax.ident.lit

	if name.len == 0 {
		// This means it was inserted by the parser and error
		// is already reporterd, just return error expression
		return new_bound_literal_expr(0)
	}
	bound_expr := b.bind_expr(syntax.expr)

	// check is varable exist in scope
	mut var := b.scope.lookup_var(name) or {
		// var have to be declared with := to be able to set a value
		b.log.error_var_not_exists(name, syntax.ident.pos)
		return bound_expr
	}

	if !var.is_mut {
		// trying to assign a nom a mutable var
		b.log.error_assign_non_mutable_variable(name, syntax.eq_tok.pos)
	}

	if bound_expr.typ() != var.typ {
		b.log.error_cannot_convert_variable_type(bound_expr.typ().name, var.typ.name,
			syntax.expr.pos())
		return bound_expr
	}
	return new_bound_assign_expr(var, bound_expr)
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
