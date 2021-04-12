module ast

import lib.comp.util.source
import lib.comp.token

pub struct ModuleStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .module_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	module_key token.Token
	name_tok   token.Token
}

pub fn new_module_stmt(tree &SyntaxTree, module_key token.Token, name_tok token.Token) ModuleStmt {
	return ModuleStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(module_key.pos, name_tok.pos)
		child_nodes: [AstNode(module_key), name_tok]
		module_key: module_key
		name_tok: name_tok
	}
}

pub fn (e &ModuleStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ModuleStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ModuleStmt) node_str() string {
	return typeof(ex).name
}
