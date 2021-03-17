module binding

import lib.comp.util.source
import lib.comp.symbols

[heap]
pub struct BoundProgram {
pub:
	func_bodies map[string]BoundBlockStmt
	previous	&BoundProgram
	main_func   symbols.FunctionSymbol
	script_func symbols.FunctionSymbol
pub mut:
	log &source.Diagnostics
}

pub fn new_bound_program(previous &BoundProgram, log &source.Diagnostics, 
	main_func symbols.FunctionSymbol, script_func symbols.FunctionSymbol, 
	func_bodies map[string]BoundBlockStmt) &BoundProgram {
	return &BoundProgram{
		previous: previous
		log: log
		main_func: main_func
		script_func: script_func
		func_bodies: func_bodies
	}
}
