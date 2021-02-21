import lib.comp.binding
import lib.comp.types

fn test_single_scope() {
	mut scope:= binding.new_bound_scope(&binding.BoundScope(0))

	var := binding.new_variable_symbol('in_scope_var', int(types.TypeKind.int_lit), false)
	assert scope.try_declare(var) == true

	// again should result in false
	var_another := binding.new_variable_symbol('in_scope_var', int(types.TypeKind.int_lit), false)
	assert scope.try_declare(var_another) == false


	lookup_var := scope.lookup('in_scope_var') or {
		assert false 
		return
	}
	assert lookup_var.name == 'in_scope_var'
	lookup_not_exist := scope.lookup('not_exist') or {
		&binding.VariableSymbol{}
	}
	
	assert lookup_not_exist.name == ''
}

fn test_parent_scope() {
	mut parent_scope:= binding.new_bound_scope(&binding.BoundScope(0))
	mut scope:= binding.new_bound_scope(parent_scope)

	var := binding.new_variable_symbol('in_scope_var', int(types.TypeKind.int_lit), false)
	assert parent_scope.try_declare(var) == true

	// again should result in false
	var_another := binding.new_variable_symbol('in_scope_var', int(types.TypeKind.int_lit), false)
	assert parent_scope.try_declare(var_another) == false

	lookup_var := scope.lookup('in_scope_var') or {
		assert false 
		return
	}
	assert lookup_var.name == 'in_scope_var'
	lookup_not_exist := scope.lookup('not_exist') or {
		&binding.VariableSymbol{}
	}
	
	assert lookup_not_exist.name == ''
}