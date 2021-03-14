module binding

struct BoundGlobalScopeStack {
mut:
	size     int
	elements []&BoundGlobalScope
}

pub fn new_bound_global_scope_stack() BoundGlobalScopeStack {
	return BoundGlobalScopeStack{}
}

[inline]
pub fn (gs BoundGlobalScopeStack) is_empty() bool {
	return gs.size <= 0
}

pub fn (gs BoundGlobalScopeStack) peek() ?&BoundGlobalScope {
	if !gs.is_empty() {
		return gs.elements[gs.size - 1]
	} else {
		return none
	}
}

pub fn (mut gs BoundGlobalScopeStack) pop() ?&BoundGlobalScope {
	if !gs.is_empty() {
		val := gs.elements[gs.size - 1]
		gs.size--
		return val
	}
	return none
}

pub fn (mut gs BoundGlobalScopeStack) push(item &BoundGlobalScope) {
	if gs.elements.len > gs.size {
		gs.elements[gs.size] = item
	} else {
		gs.elements << item
	}
	gs.size++
}
