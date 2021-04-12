module ast

import lib.comp.util.source
import lib.comp.token

pub struct ImportStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .import_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	import_key token.Token
	name_expr   NameExpr
}

pub fn new_import_stmt(tree &SyntaxTree, import_key token.Token, name_expr NameExpr) ImportStmt {
	return ImportStmt{
		tree: tree
		pos: source.new_pos_from_pos_bounds(import_key.pos, name_expr.name_tok.pos)
		child_nodes: [AstNode(import_key), name_expr.name_tok]
		import_key: import_key
		name_expr: name_expr
	}
}

pub fn (e &ImportStmt) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex ImportStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ImportStmt) node_str() string {
	return typeof(ex).name
}
