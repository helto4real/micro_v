module ast

import lib.comp.token
import lib.comp.util.source

pub struct CallExpr {
	tok token.Token
pub:
	kind        SyntaxKind = .call_expr
	pos         source.Pos
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
		pos: source.new_pos_from_pos_bounds(ident.pos, rpar_tok.pos)
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

pub fn (ex CallExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex CallExpr) str() string {
	mut ret := '${ex.ident.lit}('
	for i := 0; i < ex.params.len(); i++ {
		param := ex.params.at(i)
		if i != 0 {
			ret = ret + ', '
		}
		ret = ret + '$param'
	}
	ret = ret + ')'
	return ret
}
