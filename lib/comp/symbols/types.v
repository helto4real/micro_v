module symbols

type VariableSymbol = LocalVariableSymbol | GlobalVariableSymbol | ParamSymbol

pub fn (vs &VariableSymbol) is_mut() bool {
	match vs {
		LocalVariableSymbol {return vs.is_mut}
		GlobalVariableSymbol {return vs.is_mut}
		ParamSymbol {return vs.is_mut}
	}
}

pub fn (vs &VariableSymbol) id() string {
	match vs {
		LocalVariableSymbol {return vs.id}
		GlobalVariableSymbol {return vs.id}
		ParamSymbol {return vs.id}
	}
}

pub fn (vs &VariableSymbol) typ() TypeSymbol {
	match vs {
		LocalVariableSymbol {return vs.typ}
		GlobalVariableSymbol {return vs.typ}
		ParamSymbol {return vs.typ}
	}
}
pub fn (vs &VariableSymbol) name() string {
	match vs {
		LocalVariableSymbol {return vs.name}
		GlobalVariableSymbol {return vs.name}
		ParamSymbol {return vs.name}
	}
}
pub fn (vs &VariableSymbol) str_ident(level int) string {
	match vs {
		LocalVariableSymbol {return vs.str_ident(level)}
		GlobalVariableSymbol {return vs.str_ident(level)}
		ParamSymbol {return vs.str_ident(level)}
	}
}