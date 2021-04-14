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
	types    map[string]symbols.TypeSymbol
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
		if bs.parent != 0 {
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

pub fn (bs &BoundScope) lookup_fn(mod string, name string) ?symbols.FunctionSymbol {
	res := symbols.built_in_functions.filter(it.name == name)
	use_mod := if res.len == 1 {
		'lib.runtime'
	} else {
		mod
	}
	unique_name := '${use_mod}.$name'
	var := bs.funcs[unique_name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_fn_parent(unique_name)
		}
		println('FUNCTION $unique_name not found in ${bs.funcs.keys()}')
		return none
	}
	return var
}

pub fn (bs &BoundScope) lookup_fn_parent(unique_name string) ?symbols.FunctionSymbol {
	var := bs.funcs[unique_name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_fn_parent(unique_name)
		}
		return none
	}
	return var
}

pub fn (bs &BoundScope) lookup_type_fn(name string, typ symbols.TypeSymbol) ?symbols.FunctionSymbol {
	unique_func_name := typ.unique_reciver_func_name(name)
	var := bs.funcs[unique_func_name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_type_fn(name, typ)
		}
		return none
	}
	return var
}

pub fn (bs &BoundScope) lookup_fn_decl(func symbols.FunctionSymbol) ?ast.FnDeclNode {
	name := func.unique_fn_name()
	var := bs.fn_decls[name] or {
		if bs.parent > 0 {
			return bs.parent.lookup_fn_decl(func)
		}
		return none
	}
	return var
}

pub fn (mut bs BoundScope) try_declare_fn(func symbols.FunctionSymbol, fn_decl ast.FnDeclNode) bool {
	name := func.unique_fn_name()
	if name in bs.funcs {
		return false
	}
	bs.funcs[name] = func
	bs.fn_decls[name] = fn_decl
	return true
}

pub fn (mut bs BoundScope) try_declare_glob_fn(func symbols.FunctionSymbol) bool {
	name := func.unique_fn_name()
	if name in bs.funcs {
		return false
	}
	bs.funcs[name] = func
	return true
}

pub fn (bs &BoundScope) lookup_type(mod string, name string) ?symbols.TypeSymbol {
	// first check if typ name is built-in?
	res := symbols.builtin_types.filter(it.name == name)
	use_mod := if res.len == 1 {
		'lib.runtime'
	} else {
		mod
	}
	unique_name := '${use_mod}.${name}'
	var := bs.types[unique_name] or {
		if bs.parent != 0 {
			return bs.parent.lookup_type_parent(unique_name)
		}
		return none
	}
	return var
}

// we duplicate this function so we do not want to lookup the 
// built in types more than once
pub fn (bs &BoundScope) lookup_type_parent(unique_name string) ?symbols.TypeSymbol {

	var := bs.types[unique_name] or {
		if bs.parent != 0 {
			return bs.parent.lookup_type_parent(unique_name)
		}
		return none
	}
	return var
}

pub fn (mut bs BoundScope) try_declare_type(type_symbol symbols.TypeSymbol) bool {
	unique_name := type_symbol.unique_name()
	if unique_name in bs.types {
		return false
	}
	bs.types[unique_name] = type_symbol
	return true
}

pub fn (mut bs BoundScope) try_replace_type(type_symbol symbols.TypeSymbol) bool {
	unique_name := type_symbol.unique_name()
	if unique_name !in bs.types {
		return false
	}
	bs.types[unique_name] = type_symbol
	return true
}

pub fn (bs &BoundScope) types() []symbols.TypeSymbol {
	mut res := []symbols.TypeSymbol{}
	for i, _ in bs.types {
		t := bs.types[i]
		res << t
	}
	return res
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
	stmts       []BoundStmt
	modules		[]string
	types       map[string]symbols.TypeSymbol
pub:
	previous &BoundGlobalScope
}

pub fn new_bound_global_scope(previous &BoundGlobalScope, diagostics &source.Diagnostics, script_func symbols.FunctionSymbol, main_func symbols.FunctionSymbol, funcs []symbols.FunctionSymbol, fn_decls []ast.FnDeclNode, vars []symbols.VariableSymbol, stmts []BoundStmt, types map[string]symbols.TypeSymbol) &BoundGlobalScope {
	return &BoundGlobalScope{
		previous: previous
		log: diagostics
		vars: vars
		script_func: script_func
		main_func: main_func
		funcs: funcs
		fn_decls: fn_decls
		stmts: stmts
		types: types
	}
}

pub fn (bg BoundGlobalScope) str() string {
	return 'BoundGlobalScope'
}
