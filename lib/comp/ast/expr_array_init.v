module ast

import strings
import lib.comp.token
import lib.comp.util.source

pub struct ArrayInitExpr {
pub:
	// general ast node
	tree        &SyntaxTree
	kind        SyntaxKind = .array_init_expr
	pos         source.Pos
	child_nodes []AstNode
	// child nodes
	lsbr_tok     token.Token
	rsbr_tok     token.Token
	exprs        []Expr // Ether values or the size expr `[expr, expr]` or `[expr]Type{}`
	len_expr     Expr   // the lenght expression
	cap_expr     Expr   // the cap expression
	init_expr    Expr   // the default value initializer expression
	is_val_array bool   // if the array is initialized with values
	is_fixed     bool   // if fixed data is allocated on stack else data is allocated on heap
}

pub fn new_value_array_init_expr(tree &SyntaxTree, lsbr_tok token.Token, exprs []Expr, rsbr_tok token.Token, is_fixed bool) ArrayInitExpr {
	mut child_nodes := [AstNode(lsbr_tok)]
	child_nodes << exprs.map(AstNode(it))
	child_nodes << rsbr_tok
	return ArrayInitExpr{
		tree: tree
		pos: source.new_pos_from_pos_bounds(lsbr_tok.pos, rsbr_tok.pos)
		child_nodes: child_nodes
		// [expr, expr]
		lsbr_tok: lsbr_tok
		exprs: exprs
		rsbr_tok: lsbr_tok
		is_val_array: true
		is_fixed: is_fixed
	}
}

pub fn (ex &ArrayInitExpr) child_nodes() []AstNode {
	return ex.child_nodes
}

pub fn (ex ArrayInitExpr) text_location() source.TextLocation {
	return source.new_text_location(ex.tree.source, ex.pos)
}

pub fn (ex ArrayInitExpr) node_str() string {
	return typeof(ex).name
}

pub fn (ex ArrayInitExpr) str() string {
	if ex.is_val_array && ex.is_fixed {
		mut b := strings.new_builder(0)
		b.write_string('[')
		for expr in ex.exprs {
			b.write_string(expr.str())
		}
		b.write_string(']!')
		return b.str()
	}

	return 'array unsupported'
}
