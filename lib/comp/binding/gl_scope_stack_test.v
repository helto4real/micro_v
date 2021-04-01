module binding

import lib.comp.util.source
import lib.comp.ast
import lib.comp.symbols

fn test_bound_global_scope_stack_basic() {
	mut stack := new_bound_global_scope_stack()
	stmts := []BoundStmt{}

	scope := new_bound_global_scope(&BoundGlobalScope(0), &source.Diagnostics(0), symbols.FunctionSymbol{}, symbols.FunctionSymbol{}, []symbols.FunctionSymbol{},
		[]ast.FnDeclNode{}, []symbols.VariableSymbol{}, stmts, map[string]symbols.TypeSymbol{})

	stack.push(scope)

	assert stack.is_empty() == false

	pop_val := stack.pop() or { &BoundGlobalScope(0) }

	assert pop_val != 0
}
