module ast

import lib.comp.token
import lib.comp.util.source

pub struct VarDeclStmt {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .var_decl_stmt
	child_nodes []AstNode
	is_mut      bool

	mut_tok token.Token
	ident   NameExpr
	eq_tok  token.Token
	expr    Expr
	pos     source.Pos
}

pub fn new_var_decl_stmt(tree &SyntaxTree, mut_tok token.Token, ident NameExpr, eq_tok token.Token, expr Expr) VarDeclStmt {
	is_mut := mut_tok.kind == .key_mut
	child_nodes := if !is_mut { [AstNode(ident.name_tok), eq_tok, expr] } else { [AstNode(mut_tok),
			ident.name_tok, eq_tok, expr] }
	pos := if !is_mut {
		source.new_pos_from_pos_bounds(ident.name_tok.pos, expr.pos)
	} else {
		source.new_pos_from_pos_bounds(mut_tok.pos, expr.pos)
	}
	return VarDeclStmt{
		tree: tree
		mut_tok: mut_tok
		ident: ident
		expr: expr
		eq_tok: eq_tok
		is_mut: is_mut
		pos: pos
		child_nodes: child_nodes
	}
}

pub fn (ae &VarDeclStmt) child_nodes() []AstNode {
	return ae.child_nodes
}

pub fn (ex VarDeclStmt) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex VarDeclStmt) node_str() string {
	return typeof(ex).name
}

pub fn (ex VarDeclStmt) str() string {
	return typeof(ex).name
}
