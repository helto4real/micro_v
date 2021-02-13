module ast
import token

fn test_number_syntax_kind() {
	assert new_number_expression(token.Token{kind: .number}, 0).kind == .number_expr
}
fn test_binary_syntax_kind() {
	assert new_binary_expression(
		new_number_expression(token.Token{kind: .number}, 0),
		token.Token{kind: .plus},
		new_number_expression(token.Token{kind: .number}, 0)).kind == .binary_expr
}

