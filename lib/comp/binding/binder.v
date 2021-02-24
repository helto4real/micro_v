// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.util
import lib.comp.types

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
	mut parent := &BoundScope(0)

	for !stack.is_empty() {
		prev = stack.pop() or { &BoundGlobalScope(0) }
		if prev == 0 {
			panic('unexpected return from stack')
		}
		mut scope := new_bound_scope(parent)
		for var in prev.vars {
			scope.try_declare(var)
		}
		parent = scope
	}

	return parent
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
			b.bind_expr_type(for_stmt.cond_expr, int(types.TypeKind.bool_lit)) 
		} else {
			BoundExpr{}
		}
		
	body_stmt := b.bind_stmt(for_stmt.body_stmt)

	return new_for_stmt(cond_expr, body_stmt, for_stmt.has_cond)
}

pub fn (mut b Binder) bind_for_range_stmt(for_range_stmt ast.ForRangeStmt) BoundStmt {
	ident_name := for_range_stmt.ident.lit

	range_expr := b.bind_expr(for_range_stmt.range_expr)
	
	// TODO: Check same type
	ident := new_variable_symbol(ident_name, range_expr.typ(), false)
	res := b.scope.try_declare(ident)
		
	body_stmt := b.bind_stmt(for_range_stmt.body_stmt)


	if res == false {
		b.log.error_name_already_defined(ident_name, for_range_stmt.ident.pos)
	}

	return new_for_range_stmt(ident, range_expr, body_stmt)
}
pub fn (mut b Binder) bind_if_stmt(if_stmt ast.IfStmt) BoundStmt {
	cond_expr := b.bind_expr_type(if_stmt.cond_expr, int(types.TypeKind.bool_lit))

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

pub fn (mut b Binder) bind_expr_type(expr ast.Expr, typ types.Type) BoundExpr {
	bound_expr := b.bind_expr(expr)

	if bound_expr.typ() != typ {
		// We expect the condition to be a boolean expression
		b.log.error_expected_correct_type_expr(typ.typ_str(), bound_expr.typ().typ_str(), expr.pos())
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
		else { panic('unexpected bound expression $expr') }
	}
}
pub fn (mut b Binder) bind_range_expr(range_expr ast.RangeExpr) BoundExpr {
	from_expr := b.bind_expr(range_expr.from)
	to_expr := b.bind_expr(range_expr.to)

	if from_expr.typ() != to_expr.typ() {
		b.log.error_expected_same_type_in_range_expr(from_expr.typ().typ_str(), range_expr.to.pos())
	}
	return new_range_expr(from_expr, to_expr)
}

pub fn (mut b Binder) bind_if_expr(if_expr ast.IfExpr) BoundExpr {
	cond_expr := b.bind_expr(if_expr.cond_expr)
	if cond_expr.typ() != int(types.TypeKind.bool_lit) {
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
	name := syntax.ident.lit
	bound_expr := b.bind_expr(syntax.expr)

	var := new_variable_symbol(name, bound_expr.typ(), syntax.is_mut)
	res := b.scope.try_declare(var)
	if res == false {
		b.log.error_name_already_defined(name, syntax.ident.pos)
	}
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
	mut var := b.scope.lookup(name) or {
		// var have to be declared with := to be able to set a value
		b.log.error_var_not_exists(name, syntax.ident.pos)
		return bound_expr
	}

	if !var.is_mut {
		// trying to assign a nom a mutable var
		b.log.error_assign_non_mutable_variable(name, syntax.eq_tok.pos)
	}

	if bound_expr.typ() != var.typ {
		b.log.error_cannot_convert_variable_type(bound_expr.typ_str(), var.typ.typ_str(),
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
		return new_bound_literal_expr(0)
	}
	variable := b.scope.lookup(name) or {
		b.log.error_var_not_exists(name, syntax.ident.pos)
		return new_bound_literal_expr(0)
	}
	return new_bound_variable_expr(variable)
}

fn (mut b Binder) bind_literal_expr(syntax ast.LiteralExpr) BoundExpr {
	val := syntax.val
	return new_bound_literal_expr(val)
}
