module ast

import lib.comp.token
import lib.comp.util.source

pub struct CallExpr {
	tok token.Token
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .call_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	lpar_tok token.Token
	name_tok token.Token
	params   SeparatedSyntaxList
	rpar_tok token.Token
}

pub fn new_call_expr(tree &SyntaxTree, name_tok token.Token, lpar_tok token.Token, params SeparatedSyntaxList, rpar_tok token.Token) CallExpr {
	mut child_nodes := [AstNode(name_tok), lpar_tok]
	for i := 0; i < params.len(); i++ {
		child_nodes << params.at(i)
	}
	child_nodes << rpar_tok

	return CallExpr{
		tree: tree
		pos: source.new_pos_from_pos_bounds(name_tok.pos, rpar_tok.pos)
		child_nodes: child_nodes
		name_tok: name_tok
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
	}
}

pub fn (le &CallExpr) child_nodes() []AstNode {
	return le.child_nodes
}

pub fn (ex CallExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex CallExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex CallExpr) str() string {
	mut ret := '${ex.name_tok.lit}('
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
