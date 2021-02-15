// bidning module binds to the syntax tree and handle checks
module binding

import lib.comp.ast
import lib.comp.util

pub struct Binder {
	table &SymbolTable
pub mut:
	log util.Diagnostics // errors when parsing
}

pub fn new_binder(table &SymbolTable) Binder {
	return Binder{
		table: table
	}
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
	var := b.table.vars[name] or {
		// var does not exists in the the symbol table
		if !is_decl {
			// var have to be declared with := to be able to set a value
			b.log.error_var_not_exists(name, syntax.ident.pos)
			return new_bound_literal_expr(0)
		}
		bound_expr := b.bind_expr(syntax.expr)
		return new_bound_assign_expr(name, syntax.is_mut, bound_expr)
	}
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
	bound_expr := b.bind_expr(syntax.expr)
	return new_bound_assign_expr(name, syntax.is_mut, bound_expr)
}

fn (mut b Binder) bind_para_expr(syntax ast.ParaExpr) BoundExpr {
	return b.bind_expr(syntax.expr)
}

fn (mut b Binder) bind_name_expr(syntax ast.NameExpr) BoundExpr {
	name := syntax.ident_tok.lit
	value := b.table.vars[name] or {
		b.log.error_var_not_exists(name, syntax.ident_tok.pos)
		return new_bound_literal_expr(0)
	}
	return new_bound_variable_expr(name, value.val.typ())
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
