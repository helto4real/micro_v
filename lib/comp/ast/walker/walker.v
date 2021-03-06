module walker

import lib.comp.ast

// Visitor defines a visit method which is invoked by the walker in each node it encounters.
pub interface Visitor {
	visit(node ast.Node) ?
}

pub interface VisitorTree {
	visit_tree(node ast.Node, last_child bool, tree_info string) ?string
}

pub type InspectorFn = fn (node ast.Node, data voidptr) bool

struct Inspector {
	inspector_callback InspectorFn
mut:
	data voidptr
}

pub fn (i &Inspector) visit(node ast.Node) ? {
	if i.inspector_callback(node, i.data) {
		return
	}
	return none
}

// inspect traverses and checks the AST node on a depth-first order and based on the data given
pub fn inspect(node ast.Node, data voidptr, inspector_callback InspectorFn) {
	walk(Inspector{inspector_callback, data}, node)
}

// walk traverses the AST using the given visitor
pub fn walk(visitor Visitor, node ast.Node) {
	visitor.visit(node) or { return }
	children := node.child_nodes()
	for child_node in children {
		walk(visitor, &child_node)
	}
}

fn walk_tree_recursive(visitor VisitorTree, node ast.Node, last_child bool, tree_info string) {
	t_info := visitor.visit_tree(node, last_child, tree_info) or { return }
	children := node.child_nodes()
	for i, child_node in children {
		walk_tree_recursive(visitor, &child_node, i == children.len - 1, t_info)
	}
}

pub fn walk_tree(visitor VisitorTree, node ast.Node) {
	walk_tree_recursive(visitor, node, true, '')
}
