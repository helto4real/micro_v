module golang

import lib.comp.io
import lib.comp.symbols

pub fn write_symbol(writer io.CodeWriter, symbol symbols.Symbol) {
	match symbol {
		symbols.VariableSymbol {
			write_var_symbol(writer, symbol)
		}
		// BoundStmt { write_stmt(writer, node) }
		symbols.FunctionSymbol {
			write_function_symbol(writer, symbol)
		}
		symbols.TypeSymbol {
			write_type_symbol(writer, symbol)
		}
		symbols.ConstSymbol {
			write_const_symbol(writer, symbol)
		}
	}
}

fn write_param_symbol(writer io.CodeWriter, param_symbol symbols.ParamSymbol) {
	// if param_symbol.is_mut {
	// 	writer.write('mut')
	// 	writer.write_space()
	// }
	writer.write(param_symbol.name)
	writer.write_space()
	write_type_symbol(writer, param_symbol.typ)
}

fn write_function_symbol(writer io.CodeWriter, fn_symbol symbols.FunctionSymbol) {
	writer.write('func')
	writer.write_space()
	writer.write(fn_symbol.name)
	writer.write('(')
	for i, param in fn_symbol.params {
		if i != 0 {
			writer.write(',')
			writer.write_space()
		}
		write_param_symbol(writer, param)
	}
	writer.write(')')
	if fn_symbol.typ != symbols.void_symbol {
		writer.write_space()
		write_type_symbol(writer, fn_symbol.typ)
	}
}

fn write_type_symbol(writer io.CodeWriter, type_symbol symbols.TypeSymbol) {
	writer.write(type_symbol.name)
}

fn write_const_symbol(writer io.CodeWriter, const_symbol symbols.ConstSymbol) {
	writer.write(const_symbol.val.str())
}

fn write_var_symbol(writer io.CodeWriter, var_symbol symbols.VariableSymbol) {
	match var_symbol {
		symbols.LocalVariableSymbol {}
		symbols.GlobalVariableSymbol {}
		symbols.ParamSymbol {
			write_param_symbol(writer, var_symbol)
		}
	}
}
