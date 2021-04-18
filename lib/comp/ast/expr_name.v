module ast

import strings
import lib.comp.token
import lib.comp.util.source

pub struct NameExpr {
pub:
	is_c_name bool
	is_ref    bool
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .name_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	ref_tok  token.Token
	name_tok token.Token
	names    []token.Token
	name     string
}

pub fn new_ref_name_expr(tree &SyntaxTree, ref_tok token.Token, names []token.Token, is_c_name bool) NameExpr {
	if ref_tok.kind == .void {
		return new_name_expr(tree, names, is_c_name)
	}
	// name_tok := merge_names(names)
	name_tok, name := merge_names(names)
	mut child_nodes := [AstNode(ref_tok)]
	for n in names {
		child_nodes << n
	}
	return NameExpr{
		tree: tree
		ref_tok: ref_tok
		name: name
		name_tok: name_tok
		names: names
		pos: source.new_pos_from_pos_bounds(ref_tok.pos, names[names.len - 1].pos)
		child_nodes: child_nodes
		is_c_name: is_c_name
		is_ref: true
	}
}

pub fn new_name_expr(tree &SyntaxTree, names []token.Token, is_c_name bool) NameExpr {
	name_tok, name := merge_names(names)
	mut child_nodes := []AstNode{}
	for n in names {
		child_nodes << n
	}
	return NameExpr{
		tree: tree
		ref_tok: token.tok_void
		name_tok: name_tok
		name: name
		names: names
		pos: source.new_pos_from_pos_bounds(names[0].pos, names[names.len - 1].pos)
		child_nodes: child_nodes
		is_c_name: is_c_name
		is_ref: false
	}
}

pub fn (ne &NameExpr) child_nodes() []AstNode {
	return ne.child_nodes
}

pub fn (ex NameExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex NameExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex NameExpr) str() string {
	return '$ex.name'
}

fn merge_names(names []token.Token) (token.Token, string) {
	if names.len == 1 {
		return names[0], names[0].lit
	}
	mut b := strings.new_builder(20)
	for i, tok in names {
		if i != 0 {
			b.write_string('.')
		}
		b.write_string(tok.lit)
	}
	mut name := b.str()
	token := token.Token{
		source: names[0].source
		kind: .name
		lit: name
		pos: source.new_pos_from_pos_bounds(names[0].pos, names[names.len - 1].pos)
	}

	return token, name
}

// fn merge_names(names []token.Token) string {
// 	if names.len == 1 {
// 		return names[0].lit
// 	}
// 	mut b := strings.new_builder(20)
// 	for i, tok in names {
// 		if i != 0 {
// 			b.write_string('.')
// 		}
// 		b.write_string(tok.lit)
// 	}
// 	return b.str()
// }
