module util

struct Stack {
mut:
	size     int
	elements []voidptr
}

pub fn new_stack() Stack {
	return Stack{}
}

[inline]
pub fn (stack Stack) is_empty() bool {
	return stack.size <= 0
}

pub fn (stack Stack) peek() ?voidptr {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	} else {
		return none
	}
}

pub fn (mut stack Stack) pop() ?voidptr {
	if !stack.is_empty() {
		val := stack.elements[stack.size - 1]
		stack.size--
		return val
	}
	return none
}

pub fn (mut stack Stack) push(item voidptr) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}