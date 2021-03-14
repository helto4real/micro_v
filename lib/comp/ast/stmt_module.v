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
	tok_module token.Token
	tok_name   token.Token
}

pub fn new_module_stmt(tree &SyntaxTree, tok_module token.Token, tok_name token.Token) ModuleStmt {
	return ModuleStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(tok_module.pos, tok_name.pos)
		child_nodes: [AstNode(tok_module)]
		tok_module: tok_module
		tok_name: tok_name
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
