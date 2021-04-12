module symbols

pub type VariableSymbol = GlobalVariableSymbol | LocalVariableSymbol | ParamSymbol

pub type TypeSymbol = AnyTypeSymbol | ArrayTypeSymbol | BuiltInTypeSymbol | ErrorTypeSymbol |
	StructTypeSymbol | VoidTypeSymbol

pub type Symbol = ConstSymbol | FunctionSymbol | TypeSymbol | VariableSymbol

pub struct NoneStruct {}

pub type None = NoneStruct

pub type LitVal = None | bool | byte | char | i64 | int | string

pub enum TypeSymbolKind {
	// builtin types
	int_symbol
	i64_symbol
	byte_symbol
	char_symbol
	bool_symbol
	string_symbol
	voidptr_symbol
	undefined_symbol
	none_symbol
	// other types
	array_symbol
	struct_symbol
	void_symbol
	error_symbol
	any_symbol
}

pub fn (vs &VariableSymbol) is_mut() bool {
	match vs {
		LocalVariableSymbol { return vs.is_mut }
		GlobalVariableSymbol { return vs.is_mut }
		ParamSymbol { return vs.is_mut }
	}
}

pub fn (vs &VariableSymbol) is_ref() bool {
	match vs {
		LocalVariableSymbol { return vs.is_ref }
		GlobalVariableSymbol { return vs.is_ref }
		ParamSymbol { return vs.is_ref }
	}
}

pub fn (vs VariableSymbol) str_ident(level int) string {
	match vs {
		LocalVariableSymbol { return vs.str_ident(level) }
		GlobalVariableSymbol { return vs.str_ident(level) }
		ParamSymbol { return vs.str_ident(level) }
	}
}

pub fn (t TypeSymbol) to_ref_type() TypeSymbol {
	match t {
		StructTypeSymbol { return t.to_ref_type() }
		AnyTypeSymbol { return t.to_ref_type() }
		BuiltInTypeSymbol { return t.to_ref_type() }
		else { panic('the type $t.name should never be a ref type') }
	}
}

pub fn (t TypeSymbol) unique_reciver_func_name(func_name string) string {
	return '${t.mod}.${t.name}.$func_name'
}

pub fn (t TypeSymbol) unique_name() string {
	return '${t.mod}.$t.name'
}

pub fn (typ TypeSymbol) lookup_member_type(name string) TypeSymbol {
	match typ {
		StructTypeSymbol {
			member := typ.members.filter(it.ident == name)
			if member.len == 0 {
				return error_symbol
			}
			return member[0].typ
		}
		else {
			return error_symbol
		}
	}
	return error_symbol
}

pub fn (typ TypeSymbol) lookup_member_index(name string) int {
	match typ {
		StructTypeSymbol {
			for i, member in typ.members {
				if member.ident == name {
					return i
				}
			}
		}
		else {
			return -1
		}
	}
	return -1
}

pub fn (t TypeSymbol) str() string {
	match t {
		StructTypeSymbol {
			return t.str()
		}
		BuiltInTypeSymbol {
			return t.str()
		}
		ArrayTypeSymbol {
			return t.str()
		}
		VoidTypeSymbol {
			return t.str()
		}
		ErrorTypeSymbol {
			return t.str()
		}
		AnyTypeSymbol {
			return t.str()
		}
	}
}

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
		i64 {
			l == (r as i64)
		}
		byte {
			l == (r as byte)
		}
		char {
			l == (r as char)
		}
		bool {
			l == (r as bool)
		}
		None {
			l == (r as None)
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

pub fn (l LitVal) typ() BuiltInTypeSymbol {
	return match l {
		string {
			string_symbol
		}
		int {
			int_symbol
		}
		i64 {
			i64_symbol
		}
		byte {
			byte_symbol
		}
		char {
			char_symbol
		}
		bool {
			bool_symbol
		}
		None {
			none_symbol
		}
	}
}

pub fn (l LitVal) str() string {
	return match l {
		string {
			l.str()
		}
		int, i64, byte, char {
			l.str()
		}
		bool {
			l.str()
		}
		None {
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
