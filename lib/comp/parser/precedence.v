module parser

import lib.comp.token

// binary_operator_precedence returns the precedence of operator
fn binary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.div, .mul { 4 }
		.plus, .minus { 3 }
		.amp_amp { 2 }
		.pipe_pipe { 1 }
		else { 0 }
	}
}

// binary_operator_precedence returns the precedence of operator
fn unary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.plus, .minus, .not{5}
		else {0}
	}
}
