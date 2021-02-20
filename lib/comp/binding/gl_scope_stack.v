module binding

import lib.comp.util

struct BoundGlobalScopeStack {
mut:
	stack util.Stack
}

pub fn new_bound_global_scope_stack() BoundGlobalScopeStack {
	return BoundGlobalScopeStack {}
}

fn (mut bss BoundGlobalScopeStack) push(bound_scope &BoundGlobalScope) {
	bss.stack.push(bound_scope)
}

fn (mut bss BoundGlobalScopeStack) pop() ?&BoundGlobalScope {
	bound_scope := bss.stack.pop() or {return none}
	return &BoundGlobalScope(bound_scope)
}

fn (bss BoundGlobalScopeStack) peek() ?&BoundGlobalScope {
	bound_scope := bss.stack.peek() or {return none}
	return &BoundGlobalScope(bound_scope)
}

[inline]
fn (bss BoundGlobalScopeStack) is_empty() bool {
	return bss.stack.is_empty()
}