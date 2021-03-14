module binding

import lib.comp.util.source

[heap]
pub struct BoundProgram {
pub:
	func_bodies map[string]BoundBlockStmt
	stmt        BoundBlockStmt
	previous	&BoundProgram
pub mut:
	log &source.Diagnostics
}

pub fn new_bound_program(previous &BoundProgram, log &source.Diagnostics, stmt BoundBlockStmt, func_bodies map[string]BoundBlockStmt) &BoundProgram {
	return &BoundProgram{
		previous: previous
		log: log
		stmt: stmt
		func_bodies: func_bodies
	}
}
