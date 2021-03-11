module symbols

pub type VariableSymbol = GlobalVariableSymbol | LocalVariableSymbol | ParamSymbol

pub type Symbol = FunctionSymbol | TypeSymbol | VariableSymbol

pub fn (vs &Symbol) id() string {
	match vs {
		VariableSymbol { return vs.id() }
		FunctionSymbol { return vs.id }
		TypeSymbol { return vs.id }
	}
}

pub fn (vs &VariableSymbol) is_mut() bool {
	match vs {
		LocalVariableSymbol { return vs.is_mut }
		GlobalVariableSymbol { return vs.is_mut }
		ParamSymbol { return vs.is_mut }
	}
}

pub fn (vs &VariableSymbol) id() string {
	match vs {
		LocalVariableSymbol { return vs.id }
		GlobalVariableSymbol { return vs.id }
		ParamSymbol { return vs.id }
	}
}

pub fn (vs &VariableSymbol) str_ident(level int) string {
	match vs {
		LocalVariableSymbol { return vs.str_ident(level) }
		GlobalVariableSymbol { return vs.str_ident(level) }
		ParamSymbol { return vs.str_ident(level) }
	}
}
