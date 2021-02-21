module parser

import lib.comp.token

// binary_operator_precedence returns the precedence of operator
fn binary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.div, .mul { 5 }
		.plus, .minus { 4 }
		.eq_eq, .exl_mark_eq { 3 }
		.amp_amp { 2 }
		.pipe_pipe { 1 }
		else { 0 }
	}
}

// binary_operator_precedence returns the precedence of operator
fn unary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.plus, .minus, .exl_mark { 6 }
		else { 0 }
	}
}
