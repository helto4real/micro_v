module symbols

import lib.comp.io

pub fn write_symbol(writer io.TermTextWriter, symbol Symbol) {
	match symbol {
		VariableSymbol {
			write_var_symbol(writer, symbol)
		}
		// BoundStmt { write_stmt(writer, node) }
		FunctionSymbol {
			write_function_symbol(writer, symbol)
		}
		TypeSymbol {
			write_type_symbol(writer, symbol)
		}
	}
}

fn write_param_symbol(writer io.TermTextWriter, param_symbol ParamSymbol) {
	if param_symbol.is_mut {
		writer.write_keyword('mut')
		writer.write_space()
	}
	writer.write_identifier(param_symbol.name)
	writer.write_space()
	write_type_symbol(writer, param_symbol.typ)
}

fn write_function_symbol(writer io.TermTextWriter, fn_symbol FunctionSymbol) {
	writer.write_keyword('fn')
	writer.write_space()
	writer.write_identifier(fn_symbol.name)
	writer.write_punctuation('(')
	for i, param in fn_symbol.params {
		if i != 0 {
			writer.write_punctuation(',')
			writer.write_space()
		}
		write_param_symbol(writer, param)
	}
	writer.write_punctuation(')')
	if fn_symbol.typ != void_symbol {
		writer.write_space()
		write_type_symbol(writer, fn_symbol.typ)
	}
	writer.writeln('')
}

fn write_type_symbol(writer io.TermTextWriter, type_symbol TypeSymbol) {
	writer.write_identifier(type_symbol.name)
}

fn write_var_symbol(writer io.TermTextWriter, var_symbol VariableSymbol) {
	match var_symbol {
		LocalVariableSymbol {}
		GlobalVariableSymbol {}
		ParamSymbol {
			write_param_symbol(writer, var_symbol)
		}
	}
}
