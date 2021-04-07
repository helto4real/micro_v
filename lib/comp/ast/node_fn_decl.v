module ast

import lib.comp.token
import lib.comp.util.source

pub struct FnDeclNode {
pub:
	is_c_decl bool
	is_pub    bool
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .fn_decl_node
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	pub_key   token.Token
	fn_key    token.Token
	receiver_node ReceiverNode
	name_expr NameExpr
	lpar_tok  token.Token
	params    SeparatedSyntaxList
	rpar_tok  token.Token
	typ_node  TypeNode

	block BlockStmt
}

pub fn new_empty_fn_decl_node(tree &SyntaxTree) FnDeclNode {
	return FnDeclNode{
		tree: tree
	}
}

pub fn new_fn_decl_node(tree &SyntaxTree, pub_key token.Token, fn_key token.Token, receiver_node ReceiverNode, name_expr NameExpr, lpar_tok token.Token, params SeparatedSyntaxList, rpar_tok token.Token, typ_node TypeNode, block BlockStmt) FnDeclNode {
	is_pub := pub_key.kind != .void
	is_c_decl := name_expr.is_c_name

	mut child_nodes := if is_pub { [AstNode(fn_key), Expr(name_expr), lpar_tok] } else { [
			AstNode(pub_key), fn_key, Expr(name_expr), lpar_tok] }
	pos := if is_pub {
		source.new_pos_from_pos_bounds(fn_key.pos, block.pos)
	} else {
		source.new_pos_from_pos_bounds(pub_key.pos, block.pos)
	}
	for i := 0; i < params.len(); i++ {
		child_nodes << params.at(i)
	}
	child_nodes << rpar_tok
	child_nodes << typ_node

	return FnDeclNode{
		tree: tree
		pos: pos
		child_nodes: child_nodes
		pub_key: pub_key
		fn_key: fn_key
		receiver_node: receiver_node
		name_expr: name_expr
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
		typ_node: typ_node
		block: block
		is_pub: is_pub
		is_c_decl: is_c_decl
	}
}

pub fn (e &FnDeclNode) child_nodes() []AstNode {
	return e.child_nodes
}

pub fn (ex FnDeclNode) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex FnDeclNode) node_str() string {
	return typeof(ex).name
}

pub fn (ex &FnDeclNode) str() string {
	return 'fn ${ex.name_expr.name_tok.lit}()'
}
