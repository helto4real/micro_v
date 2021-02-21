module binding
import strings
import lib.comp.util
pub struct BoundScope {
mut:
	vars   map[string]&VariableSymbol
pub:
	parent &BoundScope
}

pub fn new_bound_scope(parent &BoundScope) &BoundScope {
	return &BoundScope{
		parent: parent
		vars: map[string]&VariableSymbol{}
	}
}

pub fn (bs &BoundScope) lookup(name string) ?&VariableSymbol {
	var :=  bs.vars[name] or {
		if bs.parent > 0 {
			return bs.parent.lookup(name)
		} 
		return none
	}
	return var
}

pub fn (mut bs BoundScope) try_declare(var &VariableSymbol) bool {
	if var.name in bs.vars {
		return false
	}
	bs.vars[var.name] = var
	return true
}

pub fn (bs &BoundScope) vars() []&VariableSymbol {
	mut res := []&VariableSymbol{}
	for i, _ in bs.vars {
		v := bs.vars[i]
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
	b.writeln('${ident}[')
	for i, _ in bs.vars {
		var := bs.vars[i]
		b.writeln('  ${var.str_ident(level)}')
		// b.write(', ')
	}
	// if bs.vars.len > 0 {
	// 	b.go_back(2)
	// }
	if bs.parent != 0 {
		b.writeln('${ident}  parent : {')
		b.write(bs.parent.str_indent(level+1))
	}
	b.writeln('${ident}]')
	return b.str()
}

pub struct BoundGlobalScope {
pub mut:
	log &util.Diagnostics // errors when parsing
	vars   []&VariableSymbol
pub:
	previous &BoundGlobalScope
	stmt BoundStmt   
}

pub fn new_bound_global_scope(previous &BoundGlobalScope, diagostics &util.Diagnostics, vars []&VariableSymbol, stmt BoundStmt) &BoundGlobalScope {
	return &BoundGlobalScope {
		previous: previous
		log: diagostics
		vars: vars
		stmt: stmt

	}
}