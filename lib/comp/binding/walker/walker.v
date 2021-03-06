module walker

import lib.comp.binding

// Visitor defines a visit method which is invoked by the walker in each node it encounters.
pub interface Visitor {
	visit(node binding.BoundNode) ?
}

pub interface VisitorTree {
	visit_btree(node binding.BoundNode, last_child bool, tree_info string) ?string
}

pub type InspectorFn = fn (node binding.BoundNode, data voidptr) bool

struct Inspector {
	inspector_callback InspectorFn
mut:
	data voidptr
}

pub fn (i &Inspector) visit(node binding.BoundNode) ? {
	if i.inspector_callback(node, i.data) {
		return
	}
	return none
}

// inspect traverses and checks the AST node on a depth-first order and based on the data given
pub fn inspect(node binding.BoundNode, data voidptr, inspector_callback InspectorFn) {
	walk(Inspector{inspector_callback, data}, node)
}

// walk traverses the AST using the given visitor
pub fn walk(visitor Visitor, node binding.BoundNode) {
	visitor.visit(node) or { return }
	children := node.child_nodes()
	for child_node in children {
		walk(visitor, &child_node)
	}
}

fn walk_tree_recursive(visitor VisitorTree, node binding.BoundNode, last_child bool, tree_info string) {
	t_info := visitor.visit_btree(node, last_child, tree_info) or { return }
	children := node.child_nodes()
	for i, child_node in children {
		walk_tree_recursive(visitor, &child_node, i == children.len - 1, t_info)
	}
}

pub fn walk_tree(visitor VisitorTree, node binding.BoundNode) {
	walk_tree_recursive(visitor, node, true, '')
}
