module ast
import token

fn test_number_syntax_kind() {
	assert new_literal_expr(token.Token{kind: .number}, 0).kind == .literal_expr
}
fn test_binary_syntax_kind() {
	assert new_binary_expr(
		new_literal_expr(token.Token{kind: .number}, 0),
		token.Token{kind: .plus},
		new_literal_expr(token.Token{kind: .number}, 0)).kind == .binary_expr
}

