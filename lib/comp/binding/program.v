module binding

import lib.comp.util

pub struct BoundProgram {
pub:
	func_bodies map[string]BoundBlockStmt
	stmt        BoundBlockStmt
pub mut:
	log         &util.Diagnostics
}

pub fn new_bound_program(log &util.Diagnostics, stmt BoundBlockStmt, func_bodies map[string]BoundBlockStmt) BoundProgram {
	return BoundProgram{
		log: log
		stmt: stmt
		func_bodies: func_bodies
	}
}
