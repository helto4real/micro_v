module binding

import lib.comp.util
import lib.comp.ast
import lib.comp.symbols

fn test_bound_global_scope_stack_basic() {
	mut stack := new_bound_global_scope_stack()

	scope := new_bound_global_scope(&BoundGlobalScope(0), &util.Diagnostics(0), []symbols.FunctionSymbol{},
		[]ast.FnDeclNode, []symbols.VariableSymbol{}, BoundBlockStmt{})


	stack.push(scope)

	assert stack.is_empty() == false

	pop_val := stack.pop() or { &BoundGlobalScope(0) }

	assert pop_val != 0
	// assert pop_val.val == 100
}
