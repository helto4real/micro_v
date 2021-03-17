module binding

import strings
import lib.comp.ast
import lib.comp.util.source
import lib.comp.symbols

pub struct BoundScope {
mut:
	vars     map[string]symbols.VariableSymbol
	funcs    map[string]symbols.FunctionSymbol
	fn_decls map[string]ast.FnDeclNode
pub:
	parent &BoundScope
}

pub fn new_bound_scope(parent &BoundScope) &BoundScope {
	return &BoundScope{
		parent: parent
		vars: map[string]symbols.VariableSymbol{}
		funcs: map[string]symbols.FunctionSymbol{}
	}
}

pub fn (bs &BoundScope) lookup_var(name string) ?symbols.VariableSymbol {
	var := bs.vars[name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_var(name)
		}
		return none
	}
	return var
}

pub fn (mut bs BoundScope) try_declare_var(var symbols.VariableSymbol) bool {
	if var.name in bs.vars {
		return false
	}
	bs.vars[var.name] = var
	return true
}

pub fn (bs &BoundScope) lookup_fn(name string) ?symbols.FunctionSymbol {
	var := bs.funcs[name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_fn(name)
		}
		return none
	}
	return var
}

pub fn (bs &BoundScope) lookup_fn_decl(name string) ?ast.FnDeclNode {
	var := bs.fn_decls[name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_fn_decl(name)
		}
		return none
	}
	return var
}

pub fn (mut bs BoundScope) try_declare_fn(func symbols.FunctionSymbol, fn_decl ast.FnDeclNode) bool {
	if func.name in bs.funcs {
		return false
	}
	bs.funcs[func.name] = func
	bs.fn_decls[func.name] = fn_decl
	return true
}

pub fn (mut bs BoundScope) try_declare_glob_fn(func symbols.FunctionSymbol) bool {
	if func.name in bs.funcs {
		return false
	}
	bs.funcs[func.name] = func
	return true
}

pub fn (bs &BoundScope) vars() []symbols.VariableSymbol {
	mut res := []symbols.VariableSymbol{}
	for i, _ in bs.vars {
		v := bs.vars[i]
		res << v
	}
	return res
}

pub fn (bs &BoundScope) funcs() []symbols.FunctionSymbol {
	mut res := []symbols.FunctionSymbol{}
	for i, _ in bs.funcs {
		v := bs.funcs[i]
		res << v
	}
	return res
}

pub fn (bs &BoundScope) func_decls() []ast.FnDeclNode {
	mut res := []ast.FnDeclNode{}
	for i, _ in bs.fn_decls {
		v := bs.fn_decls[i]
		res << v
	}
	return res
}

pub fn (bs &BoundScope) str() string {
	return bs.str_indent(0)
}

fn (bs &BoundScope) str_indent(level int) string {
	ident := '  '.repeat(level)
	mut b := strings.new_builder(0)
	b.writeln('${ident}BS(${voidptr(bs)})')
	b.writeln('$ident[')
	for i, _ in bs.vars {
		var := bs.vars[i]
		b.writeln('  ${var.str_ident(level)}')
	}
	if bs.parent != 0 {
		b.writeln('$ident  parent : {')
		b.write_string(bs.parent.str_indent(level + 1))
	}
	b.writeln('$ident]')
	return b.str()
}

pub struct BoundGlobalScope {
pub mut:
	log         &source.Diagnostics // errors when parsing
	vars        []symbols.VariableSymbol
	main_func   symbols.FunctionSymbol
	script_func symbols.FunctionSymbol
	funcs       []symbols.FunctionSymbol
	fn_decls    []ast.FnDeclNode
	stmts    	[]BoundStmt
pub:
	previous &BoundGlobalScope
}

pub fn new_bound_global_scope(previous &BoundGlobalScope, diagostics &source.Diagnostics, script_func symbols.FunctionSymbol, main_func symbols.FunctionSymbol, funcs []symbols.FunctionSymbol, fn_decls []ast.FnDeclNode, vars []symbols.VariableSymbol, stmts []BoundStmt) &BoundGlobalScope {
	return &BoundGlobalScope{
		previous: previous
		log: diagostics
		vars: vars
		script_func: script_func
		main_func: main_func
		funcs: funcs
		fn_decls: fn_decls
		stmts: stmts
	}
}
