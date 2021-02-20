module binding

import lib.comp.util

struct BoundScopeStack {
mut:
	stack util.Stack
}

pub fn new_bound_scope_stack() BoundScopeStack {
	return BoundScopeStack {}
}

fn (mut bss BoundScopeStack) push(bound_scope &BoundScope) {
	bss.stack.push(bound_scope)
}

fn (mut bss BoundScopeStack) pop() ?&BoundScope {
	bound_scope := bss.stack.pop() or {return none}
	return &BoundScope(bound_scope)
}

fn (bss BoundScopeStack) peek() ?&BoundScope {
	bound_scope := bss.stack.peek() or {return none}
	return &BoundScope(bound_scope)
}

[inline]
fn (bss BoundScopeStack) is_empty() bool {
	return bss.stack.is_empty()
}


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