module binding

import lib.comp.symbols

pub struct BoundStructInitExpr {
pub:
	// general bound node
	kind        BoundNodeKind = .sruct_init_expr
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	is_ref      bool
	// child nodes
	members []BoundStructInitMember
}

pub fn new_bound_struct_init_expr(typ symbols.TypeSymbol, members []BoundStructInitMember) BoundExpr {
	return BoundStructInitExpr{
		typ: typ
		members: members
	}
}

pub fn (ex BoundStructInitExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundStructInitExpr) str() string {
	return '$ex.typ.name{}'
}

pub fn (ex BoundStructInitExpr) to_ref_type() BoundStructInitExpr {
	return BoundStructInitExpr{
		...ex
		is_ref: true
		typ: ex.typ.to_ref_type()
	}
}

pub struct BoundStructInitMember {
pub:
	name string
	typ  symbols.TypeSymbol
	expr BoundExpr
}

pub fn new_bound_struct_init_member(name string, expr BoundExpr) BoundStructInitMember {
	return BoundStructInitMember{
		typ: expr.typ
		name: name
		expr: expr
	}
}
