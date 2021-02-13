module parser

fn test_binary_operator_precedence() {
	assert binary_operator_precedence(.plus) == binary_operator_precedence(.minus)
	assert binary_operator_precedence(.div) == binary_operator_precedence(.mul)
	// only need to test this combination since mul/div and plus/minus tested same
	assert binary_operator_precedence(.mul) > binary_operator_precedence(.plus)
}