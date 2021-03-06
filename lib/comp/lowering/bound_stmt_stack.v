module lowering

import lib.comp.binding

struct BoundStmtStack {
mut:
	size     int
	elements []binding.BoundStmt
}

pub fn new_stack() BoundStmtStack {
	return BoundStmtStack{}
}

[inline]
pub fn (stack BoundStmtStack) is_empty() bool {
	return stack.size <= 0
}

pub fn (stack BoundStmtStack) peek() ?binding.BoundStmt {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	} else {
		return none
	}
}

pub fn (mut stack BoundStmtStack) pop() ?binding.BoundStmt {
	if !stack.is_empty() {
		val := stack.elements[stack.size - 1]
		stack.size--
		return val
	}
	return none
}

pub fn (mut stack BoundStmtStack) push(item binding.BoundStmt) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}
