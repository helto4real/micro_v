module types

pub type Type = int

pub type LitVal = int | string | bool

pub fn (l LitVal) typ() Type {
	return match l {
		string {
			1
		}
		int {
			2
		}
		bool {
			3
		}
	}
}
pub fn (l LitVal) typ_str() string {
	return match l {
		string {
			built_in_types[int(TypeKind.string_lit)]
		}
		int {
			built_in_types[int(TypeKind.int_lit)]
		}
		bool {
			built_in_types[int(TypeKind.bool_lit)]
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
	string_lit	= 1
	int_lit		= 2
	bool_lit	= 3
}

pub const(
	built_in_types = add_built_in_types()
)

fn add_built_in_types() map[int]string {
	mut types := map[int]string{}
	types[int(TypeKind.int_lit)] = 'int'
	types[int(TypeKind.string_lit)] = 'string'
	types[int(TypeKind.bool_lit)] = 'bool'
	return types
}