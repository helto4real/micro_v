module ast

import lib.comp.util
import lib.comp.token

pub struct ModuleStmt {
pub:
	// general ast node
	kind        SyntaxKind = .module_stmt
	pos         util.Pos
	child_nodes []AstNode
	// child nodes
	tok_module token.Token
	tok_name token.Token
}

pub fn new_module_stmt(tok_module token.Token, tok_name token.Token) ModuleStmt {
	return ModuleStmt{
		pos: tok_module.pos
		child_nodes: [AstNode(tok_module), ]
		tok_module: tok_module
		tok_name: tok_name
	}
}

pub fn (e &ModuleStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex &ModuleStmt) node_str() string {
	return typeof(ex).name
}
