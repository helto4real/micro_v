module core

import lib.comp.binding

pub type EmitNodeFn = fn (node binding.BoundNode, data voidptr)

pub interface NodeEmitter {
	emit_stmt(node binding.BoundNode)
}

// struct EmitNodeInfo {
// 	emit_node_callback EmitNodeFn
// mut:
// 	data voidptr
// }

// pub fn (i &Inspector) visit(node binding.BoundNode) ? {
// 	if i.inspector_callback(node, i.data) {
// 		return
// 	}
// 	return none
// }

// pub fn emit_stmt(node binding.BoundNode, data voidptr, inspector_callback InspectorFn) {
// 	walk(Inspector{inspector_callback, data}, node)
// }

// walk traverses the AST using the given visitor
pub fn emit_nodes(emitter NodeEmitter, node binding.BoundNode) {
	emitter.emit_stmt(node)
	children := node.child_nodes()
	for child_node in children {
		emit_nodes(emitter, child_node)
	}
}
