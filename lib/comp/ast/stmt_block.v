module ast

import lib.comp.token
import lib.comp.util.source
import strings

pub struct BlockStmt {
pub:
	// Node
	tree        &SyntaxTree
	kind        SyntaxKind = .block_stmt
	child_nodes []AstNode
	pos         source.Pos
	open_brc    token.Token
	stmts       []Stmt
	close_brc   token.Token
}

pub fn new_block_stmt(tree &SyntaxTree, open_brc token.Token, stmts []Stmt, close_brc token.Token) BlockStmt {
	mut child_nodes := [AstNode(open_brc)]
	child_nodes.insert(1, stmts.map(AstNode(it)))
	child_nodes << close_brc

	return BlockStmt{
		tree: tree
		open_brc: open_brc
		stmts: stmts
		close_brc: close_brc
		child_nodes: child_nodes
		pos: source.new_pos_from_pos_bounds(open_brc.pos, close_brc.pos)
	}
}

pub fn (bs &BlockStmt) child_nodes() []AstNode {
	return bs.child_nodes
}

pub fn (ex BlockStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex BlockStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex BlockStmt) str() string {
	mut b := strings.new_builder(0)
	b.writeln('{')
	for stmt in ex.stmts {
		b.writeln('  $stmt')
	}
	b.writeln('}')
	return b.str()
}
