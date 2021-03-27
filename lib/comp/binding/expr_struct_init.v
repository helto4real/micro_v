module binding

import lib.comp.symbols

pub struct BoundStructInitExpr {
pub:
	kind        BoundNodeKind
	typ         symbols.TypeSymbol
	child_nodes []BoundNode
	members		[]BoundStructInitMember
}

pub fn new_bound_struct_init_expr(typ symbols.TypeSymbol, members []BoundStructInitMember) BoundExpr {
	return BoundStructInitExpr{
		typ: typ
		kind: .sruct_init_expr
		members: members
	}
}

pub fn (ex BoundStructInitExpr) node_str() string {
	return 'typeof(ex).name'
}

pub fn (ex BoundStructInitExpr) str() string {
	return '${ex.typ.name}{}'
}

pub struct BoundStructInitMember {
pub:
	name		string
	typ         symbols.TypeSymbol
	bound_expr  BoundExpr
}

pub fn new_bound_struct_init_member(name string, bound_expr BoundExpr) BoundStructInitMember {
	return BoundStructInitMember{
		typ: bound_expr.typ
		name: name
		bound_expr: bound_expr
	}
}

