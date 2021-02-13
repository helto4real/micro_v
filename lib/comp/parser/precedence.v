module parser
import lib.comp.token

// binary_operator_precedence returns the precedence of operator
fn binary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.div, .mul {
			2
		}
		.plus, .minus {
			1
		}
		else {
			0
		}
	}
}

// binary_operator_precedence returns the precedence of operator
fn unary_operator_precedence(kind token.Kind) int {
	// the precedence of binary operators in order
	return match kind {
		.plus, .minus {
			3
		}
		else {
			0
		}
	}
}