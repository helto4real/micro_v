module ast

import lib.comp.token
import lib.comp.util

pub struct CallExpr {
	tok token.Token
pub:
	kind        SyntaxKind = .call_expr
	pos         util.Pos
	child_nodes []AstNode

	lpar_tok token.Token
	ident    token.Token
	params   SeparatedSyntaxList
	rpar_tok token.Token
}

pub fn new_call_expr(ident token.Token, lpar_tok token.Token, params SeparatedSyntaxList, rpar_tok token.Token) CallExpr {
	mut child_nodes := [AstNode(ident), lpar_tok]
	for i := 0; i < params.len(); i++ {
		child_nodes << params.at(i)
	}
	child_nodes << rpar_tok

	return CallExpr{
		pos: util.new_pos_from_pos_bounds(ident.pos, rpar_tok.pos)
		child_nodes: child_nodes
		ident: ident
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
	}
}

pub fn (le &CallExpr) child_nodes() []AstNode {
	return le.child_nodes
}

pub fn (ex &CallExpr) node_str() string {
	return typeof(ex).name
}

///

pub struct SeparatedSyntaxList {
mut:
	sep_and_nodes []AstNode
}

pub fn new_separated_syntax_list(sep_and_nodes []AstNode) SeparatedSyntaxList {
	return SeparatedSyntaxList{
		sep_and_nodes: sep_and_nodes
	}
}

pub fn (ssl SeparatedSyntaxList) sep_and_nodes() []AstNode {
	return ssl.sep_and_nodes
}

pub fn (ssl SeparatedSyntaxList) len() int {
	return (ssl.sep_and_nodes.len + 1) / 2
}

pub fn (mut ssl SeparatedSyntaxList) add(expr Expr) {
	ssl.sep_and_nodes << expr
}

pub fn (ssl SeparatedSyntaxList) at(index int) AstNode {
	return ssl.sep_and_nodes[index * 2]
}

pub fn (ssl SeparatedSyntaxList) sep_at(index int) AstNode {
	return ssl.sep_and_nodes[index * 2 + 1]
}
