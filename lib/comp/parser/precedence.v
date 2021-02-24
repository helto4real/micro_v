module parser

import lib.comp.token

// binary_operator_precedence returns the precedence of operator
fn binary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.div, .mul { 5 }
		.plus, .minus { 4 }
		.eq_eq, .exl_mark_eq, .gt, .lt, .gt_eq, .lt_eq { 3 }
		.amp_amp, .amp { 2 }
		.pipe_pipe, .pipe, .hat { 1 }
		else { 0 }
	}
}

// binary_operator_precedence returns the precedence of operator
fn unary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.plus, .minus, .exl_mark, .tilde { 6 }
		else { 0 }
	}
}
