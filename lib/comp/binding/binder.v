// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.util

[heap]
pub struct Binder {
pub mut:
	scope &BoundScope
	log &util.Diagnostics // errors when parsing
}

pub fn new_binder(parent &BoundScope) &Binder {
	return &Binder{
		scope: new_bound_scope(parent)
		log: util.new_diagonistics()
	}
}

pub fn bind_global_scope(previous &BoundGlobalScope, comp_node &ast.CompilationNode) &BoundGlobalScope {
	// TODO: make create_parent_scope
	parent_scope := create_parent_scope(previous)
	mut binder := new_binder(parent_scope)
	expr := binder.bind_expr(comp_node.expr)
	vars := binder.scope.vars()
	// TODO: Check if diagnostics still work
	// diagnostics := binder.log.all
	// if previous != 0 {
	// 	// TODO: fix 
	// 	diagnostics.prepend(previous.log.all) 
	// }
	return new_bound_global_scope(previous, binder.log, vars, expr)
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
		prev = stack.pop() or {&BoundGlobalScope(0)} 
		if prev == 0 {panic('unexpected return from stack')}
		mut scope := new_bound_scope(parent)
		for var in prev.vars {
			
			scope.try_declare(var)
		}
		parent = scope
	}
	// println('PARENT 2: $parent }')
	return parent
}

pub fn (mut b Binder) bind_expr(expr ast.Expression) BoundExpr {
	match expr {
		ast.LiteralExpr { return b.bind_literal_expr(expr) }
		ast.UnaryExpr { return b.bind_unary_expr(expr) }
		ast.BinaryExpr { return b.bind_binary_expr(expr) }
		ast.ParaExpr { return b.bind_para_expr(expr) }
		ast.NameExpr { return b.bind_name_expr(expr) }
		ast.AssignExpr { return b.bind_assign_expr(expr) }
		else { panic('unexpected bound expression $expr') }
	}
}

fn (mut b Binder) bind_assign_expr(syntax ast.AssignExpr) BoundExpr {
	name := syntax.ident.lit
	is_decl := syntax.eq_tok.kind == .colon_eq
	bound_expr := b.bind_expr(syntax.expr)
	mut is_declared_in_assignment := false
	mut var := b.scope.lookup(name) or {&VariableSymbol(0)}
	
	if var == 0 {
		// var does not exists in the the symbol table
		if !is_decl {
			// var have to be declared with := to be able to set a value
			b.log.error_var_not_exists(name, syntax.ident.pos)
			return new_bound_literal_expr(0)
		}
		var = new_variable_symbol(name, bound_expr.typ(), syntax.is_mut)
		is_declared_in_assignment = true
		b.scope.try_declare(var) 
	}

	if !is_declared_in_assignment {
		if is_decl {
			// var exists and it is re-declared
			b.log.error_name_already_defined(name, syntax.ident.pos)
			return new_bound_literal_expr(0)
		}
		if !var.is_mut {
			// trying to assign a nom a mutable var
			b.log.error_assign_non_mutable_variable(name, syntax.ident.pos)
			return new_bound_literal_expr(0)
		}
	}
	if bound_expr.typ() != var.typ {
		b.log.error_cannot_convert_variable_type(bound_expr.typ_str(), var.typ.typ_str(), syntax.expr.pos())
		return bound_expr
	}
	return new_bound_assign_expr(var, syntax.is_mut, bound_expr)
}

fn (mut b Binder) bind_para_expr(syntax ast.ParaExpr) BoundExpr {
	return b.bind_expr(syntax.expr)
}

fn (mut b Binder) bind_name_expr(syntax ast.NameExpr) BoundExpr {
	name := syntax.ident_tok.lit
	variable := b.scope.lookup(name) or {
		b.log.error_var_not_exists(name, syntax.ident_tok.pos)
		return new_bound_literal_expr(0)
	}
	return new_bound_variable_expr(variable)
}

fn (mut b Binder) bind_literal_expr(syntax ast.LiteralExpr) BoundExpr {
	val := syntax.val
	return new_bound_literal_expr(val)
}

enum BoundNodeKind {
	unary_expr
	binary_expr
	literal_expr
	variable_expr
	assign_expr
}
