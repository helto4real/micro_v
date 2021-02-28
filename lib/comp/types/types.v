module types
import symbols


// pub type Type = int

// pub fn (t Type) typ_str() string {
// 	return types.built_in_types[int(t)]
// }

pub struct None {}
pub type LitVal = bool | int | string

pub fn (l LitVal) eq(r LitVal) bool {
	if l.type_name() != r.type_name() {
		panic('no equals is defined between types $l.type_name() and $r.type_name()')
	}
	return match l {
		string {
			l == (r as string)
		}
		int {
			l == (r as int)
		}
		bool {
			l == (r as bool)
		}
	}
}

pub fn (l LitVal) lt(r LitVal) bool {
	if l.type_name() != r.type_name() {
		panic('no <lt> is defined between types $l.type_name() and $r.type_name()')
	}
	return match l {
		int {
			l < (r as int)
		}
		else {
			panic('no lt is defined for type besides int')
			false
		}
	}
}

pub fn (l LitVal) gt(r LitVal) bool {
	if l.type_name() != r.type_name() {
		panic('no <gt> is defined between types $l.type_name() and $r.type_name()')
	}
	return match l {
		int {
			l > (r as int)
		}
		else {
			panic('no gt is defined for type besides int')
			false
		}
	}
}

pub fn (l LitVal) ge(r LitVal) bool {
	if l.type_name() != r.type_name() {
		panic('no <ge> is defined between types $l.type_name() and $r.type_name()')
	}
	return match l {
		int {
			l >= (r as int)
		}
		else {
			panic('no ge is defined for type besides int')
			false
		}
	}
}

pub fn (l LitVal) le(r LitVal) bool {
	if l.type_name() != r.type_name() {
		panic('no <le> is defined between types $l.type_name() and $r.type_name()')
	}
	return match l {
		int {
			l <= (r as int)
		}
		else {
			panic('no le is defined for type besides int')
			false
		}
	}
}

pub fn (l LitVal) typ() symbols.TypeSymbol {
	return match l {
		string {
			symbols.string_symbol
		}
		int {
			symbols.int_symbol
		}
		bool {
			symbols.bool_symbol
		}
	}
}

pub fn (l LitVal) typ_str() string {
	return match l {
		string {
			types.built_in_types[int(TypeKind.string_lit)]
		}
		int {
			types.built_in_types[int(TypeKind.int_lit)]
		}
		bool {
			types.built_in_types[int(TypeKind.bool_lit)]
		}
	}
}

pub fn (l LitVal) str() string {
	return match l {
		string {
			l.str()
		}
		int {
			l.str()
		}
		bool {
			l.str()
		}
	}
}

enum TypeKind {
	unknown = 0
	string_lit = 1
	int_lit = 2
	bool_lit = 3
}

pub const (
	built_in_types = add_built_in_types()
)

fn add_built_in_types() map[int]string {
	mut types := map[int]string{}
	types[int(TypeKind.int_lit)] = 'int'
	types[int(TypeKind.string_lit)] = 'string'
	types[int(TypeKind.bool_lit)] = 'bool'
	return types
}
