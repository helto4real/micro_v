module binding

import lib.comp.util.source

pub struct BoundProgram {
pub:
	func_bodies map[string]BoundBlockStmt
	stmt        BoundBlockStmt
pub mut:
	log &source.Diagnostics
}

pub fn new_bound_program(log &source.Diagnostics, stmt BoundBlockStmt, func_bodies map[string]BoundBlockStmt) BoundProgram {
	return BoundProgram{
		log: log
		stmt: stmt
		func_bodies: func_bodies
	}
}
