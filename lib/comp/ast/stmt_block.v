module ast

import lib.comp.token
import lib.comp.util.source
import strings

pub struct BlockStmt {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .block_stmt
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	open_brc_tok  token.Token
	stmts         []Stmt
	close_brc_tok token.Token
}

pub fn new_void_block_stmt(tree &SyntaxTree) BlockStmt {
	return BlockStmt{
		tree: tree
	}
}

pub fn new_block_stmt(tree &SyntaxTree, open_brc_tok token.Token, stmts []Stmt, close_brc_tok token.Token) BlockStmt {
	mut child_nodes := [AstNode(open_brc_tok)]
	child_nodes.insert(1, stmts.map(AstNode(it)))
	child_nodes << close_brc_tok

	return BlockStmt{
		tree: tree
		open_brc_tok: open_brc_tok
		stmts: stmts
		close_brc_tok: close_brc_tok
		child_nodes: child_nodes
		pos: source.new_pos_from_pos_bounds(open_brc_tok.pos, close_brc_tok.pos)
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
