module lowering

struct BreakAndContinueLabels {
pub:
	break_label string
	continue_label string
}

fn new_break_and_cont_labels(break_label string, continue_label string) BreakAndContinueLabels {
	return BreakAndContinueLabels {
		break_label: break_label
		continue_label: continue_label
	}
}

struct BreakAndContinueLabelStack {
mut:
	size     int
	elements []BreakAndContinueLabels
}

pub fn new_eval_vars_stack() BreakAndContinueLabelStack {
	return BreakAndContinueLabelStack{}
}

[inline]
pub fn (stack BreakAndContinueLabelStack) is_empty() bool {
	return stack.size <= 0
}

[inline]
pub fn (stack BreakAndContinueLabelStack) len() int {
	return stack.elements.len
}

pub fn (stack BreakAndContinueLabelStack) peek() ?BreakAndContinueLabels {
	if !stack.is_empty() {
		return stack.elements[stack.size - 1]
	} else {
		return none
	}
}

pub fn (mut stack BreakAndContinueLabelStack) pop() ?BreakAndContinueLabels {
	if !stack.is_empty() {
		val := stack.elements[stack.size - 1]
		stack.size--
		return val
	}
	return none
}

pub fn (mut stack BreakAndContinueLabelStack) push(item BreakAndContinueLabels) {
	if stack.elements.len > stack.size {
		stack.elements[stack.size] = item
	} else {
		stack.elements << item
	}
	stack.size++
}
