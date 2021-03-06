module binding

import lib.comp.util

pub struct BoundProgram {
pub:
	log         &util.Diagnostics
	func_bodies map[string]BoundBlockStmt
	stmt        BoundStmt
}

pub fn new_bound_program(log &util.Diagnostics, stmt BoundStmt, func_bodies map[string]BoundBlockStmt) BoundProgram {
	return BoundProgram{
		log: log
		stmt: stmt
		func_bodies: func_bodies
	}
}
