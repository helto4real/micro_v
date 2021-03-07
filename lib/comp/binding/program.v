module binding

import lib.comp.util

pub struct BoundProgram {
pub:
	log         &util.Diagnostics
	func_bodies map[string]BoundBlockStmt
	stmt        BoundBlockStmt
}

pub fn new_bound_program(log &util.Diagnostics, stmt BoundBlockStmt, func_bodies map[string]BoundBlockStmt) BoundProgram {
	return BoundProgram{
		log: log
		stmt: stmt
		func_bodies: func_bodies
	}
}
