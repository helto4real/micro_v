import lib.comp.binding
import lib.comp.symbols

fn test_single_scope() {
	mut scope := binding.new_bound_scope(&binding.BoundScope(0))

	var := symbols.new_local_variable_symbol('main', 'in_scope_var', symbols.int_symbol, false)
	assert scope.try_declare_var(var) == true

	// again should result in false
	var_another := symbols.new_local_variable_symbol('main', 'in_scope_var', symbols.int_symbol,
		false)
	assert scope.try_declare_var(var_another) == false

	lookup_var := scope.lookup_var('in_scope_var') or {
		assert false
		return
	}
	assert lookup_var.name == 'in_scope_var'
	_ := scope.lookup_var('not_exist') or { return }

	assert false
}

fn test_parent_scope() {
	mut parent_scope := binding.new_bound_scope(&binding.BoundScope(0))
	mut scope := binding.new_bound_scope(parent_scope)

	var := symbols.new_local_variable_symbol('main', 'in_scope_var', symbols.int_symbol, false)
	assert parent_scope.try_declare_var(var) == true

	// again should result in false
	var_another := symbols.new_local_variable_symbol('main', 'in_scope_var', symbols.int_symbol,
		false)
	assert parent_scope.try_declare_var(var_another) == false

	lookup_var := scope.lookup_var('in_scope_var') or {
		assert false
		return
	}
	assert lookup_var.name == 'in_scope_var'
	_ := scope.lookup_var('not_exist') or { return }

	assert false
}
