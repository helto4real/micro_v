module symbols

pub type VariableSymbol = GlobalVariableSymbol | LocalVariableSymbol | ParamSymbol

pub type TypeSymbol = StructTypeSymbol | BuiltInTypeSymbol | VoidTypeSymbol | 
					ErrorTypeSymbol | AnyTypeSymbol 

pub type Symbol = FunctionSymbol | VariableSymbol | ConstSymbol | TypeSymbol

pub struct NoneStruct {}

pub type None = NoneStruct

pub type LitVal = None | bool | int | string

pub enum TypeSymbolKind {
	built_in_symbol
	struct_symbol
	void_symbol
	error_symbol
	any_symbol
	none_symbol
}

pub fn (vs &VariableSymbol) is_mut() bool {
	match vs {
		LocalVariableSymbol { return vs.is_mut }
		GlobalVariableSymbol { return vs.is_mut }
		ParamSymbol { return vs.is_mut }
	}
}

pub fn (vs VariableSymbol) str_ident(level int) string {
	match vs {
		LocalVariableSymbol { return vs.str_ident(level) }
		GlobalVariableSymbol { return vs.str_ident(level) }
		ParamSymbol { return vs.str_ident(level) }
	}
}

pub fn (typ TypeSymbol) lookup_member_type(name string) TypeSymbol {
	match typ {
		StructTypeSymbol { 
			member := typ.members.filter(it.ident == name)
			if member.len == 0 {
				return symbols.error_symbol
			}
			return member[0].typ
		}
		else {return symbols.error_symbol}
	}
	return symbols.error_symbol
}

pub fn (t TypeSymbol) str() string {
	match t {
		StructTypeSymbol {
			return t.str()
		} 
		BuiltInTypeSymbol {
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
		int {
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
