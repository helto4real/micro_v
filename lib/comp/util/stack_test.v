import lib.comp.util

[heap]
struct Node {
	val int
}

struct NodeStack {
mut:
	stack util.Stack
}

fn new_node_stack() NodeStack {
	return NodeStack {}
}

fn new_node(val int) &Node {
	return &Node{val:val}
}

fn (mut ns NodeStack) push(val int) {
	ns.stack.push(new_node(val))
}

fn (mut ns NodeStack) pop() ?&Node {
	val := ns.stack.pop() or {return none}
	return &Node(val)
}

fn (ns NodeStack) peek() ?&Node {
	val := ns.stack.peek() or {return none}
	return &Node(val)
}

[inline]
fn (ns NodeStack) is_empty() bool {
	return ns.stack.is_empty()
}


fn test_basic_stack_operations() {
	mut stack := new_node_stack()

	stack.push(100)

	assert stack.is_empty() == false

	pop_val := stack.pop() or {&Node(0)}

	assert pop_val != 0
	assert pop_val.val == 100

	stack.push(1)
	stack.push(2)
	stack.push(3)
	stack.push(4)
	stack.push(5)
	stack.push(6)
	stack.push(7)

	mut node := stack.pop() or {panic('')}
	assert node.val == 7

	stack.push(8)
	node = stack.pop() or {panic('')}
	assert node.val == 8
	node = stack.pop() or {panic('')}
	assert node.val == 6
	node = stack.pop() or {panic('')}
	assert node.val == 5
	node = stack.pop() or {panic('')}
	assert node.val == 4
	node = stack.pop() or {panic('')}
	assert node.val == 3
	node = stack.pop() or {panic('')}
	assert node.val == 2
	node = stack.pop() or {panic('')}
	assert node.val == 1
	node = stack.pop() or {&Node(0)}
	assert !(node != 0)

}

fn test_basic_stack_empty_stack() {
	mut stack := new_node_stack()

	assert stack.is_empty() == true
	pop_val := stack.pop() or {&Node(0)}
	if pop_val != 0 {
		assert false
	}

	stack.push(100)
	real_val := stack.pop() or {&Node(0)}
	assert real_val != 0

	assert stack.is_empty() == true
	pop_val_a := stack.pop() or {&Node(0)}
	assert !(pop_val_a != 0)

}