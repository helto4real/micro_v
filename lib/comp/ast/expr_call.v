module ast

import lib.comp.token
import lib.comp.util.source

pub struct CallExpr {
pub:
	// tok token.Token
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .call_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	lpar_tok  token.Token
	name_expr NameExpr
	params    []CallArgNode
	rpar_tok  token.Token
}

pub fn new_call_expr(tree &SyntaxTree, name_expr NameExpr, lpar_tok token.Token, params []CallArgNode, rpar_tok token.Token) CallExpr {
	mut child_nodes := [AstNode(Expr(name_expr)), lpar_tok]
	for param in params {
		child_nodes << param
	}
	child_nodes << rpar_tok

	return CallExpr{
		tree: tree
		pos: source.new_pos_from_pos_bounds(name_expr.name_tok.pos, rpar_tok.pos)
		child_nodes: child_nodes
		name_expr: name_expr
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
	mut ret := '${ex.name_expr.name_tok.lit}('
	for i, param in ex.params {
		if i != 0 {
			ret = ret + ', '
		}
		ret = ret + '$param'
	}
	ret = ret + ')'
	return ret
}

pub struct CallArgNode {
pub:
	tree        &SyntaxTree
	kind        SyntaxKind = .call_arg_node
	pos         source.Pos
	child_nodes []AstNode

	mut_tok token.Token
	expr    Expr
	is_mut  bool
}

pub fn new_call_arg_node(tree &SyntaxTree, mut_tok token.Token, expr Expr) CallArgNode {
	is_mut := mut_tok.kind == .key_mut

	child_nodes := if is_mut { [AstNode(mut_tok), expr] } else { [AstNode(expr)] }
	pos := if is_mut { source.new_pos_from_pos_bounds(mut_tok.pos, expr.pos) } else { expr.pos }
	return CallArgNode{
		tree: tree
		pos: pos
		child_nodes: child_nodes
		mut_tok: mut_tok
		expr: expr
		is_mut: is_mut
	}
}

pub fn (le &CallArgNode) child_nodes() []AstNode {
	return le.child_nodes
}

pub fn (ex CallArgNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex CallArgNode) node_str() string {
	return typeof(ex).name
}

pub fn (ex CallArgNode) str() string {
	if ex.is_mut {
		return 'mut $ex.expr'
	}
	return '$ex.expr'
}
