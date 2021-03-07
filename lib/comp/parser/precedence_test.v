module parser
import lib.comp.ast

fn test_binary_operator_precedence() {
	assert ast.binary_operator_precedence(.plus) == ast.binary_operator_precedence(.minus)
	assert ast.binary_operator_precedence(.div) == ast.binary_operator_precedence(.mul)
	assert ast.binary_operator_precedence(.lt) == ast.binary_operator_precedence(.eq_eq)
	assert ast.binary_operator_precedence(.gt) == ast.binary_operator_precedence(.eq_eq)
	assert ast.binary_operator_precedence(.gt_eq) == ast.binary_operator_precedence(.eq_eq)
	assert ast.binary_operator_precedence(.lt_eq) == ast.binary_operator_precedence(.eq_eq)
	// only need to test this combination since mul/div and plus/minus tested same
	assert ast.binary_operator_precedence(.mul) > ast.binary_operator_precedence(.plus)
	// unary operator
	assert ast.unary_operator_precedence(.minus) > ast.binary_operator_precedence(.plus)
	assert ast.unary_operator_precedence(.plus) > ast.binary_operator_precedence(.plus)
	assert ast.unary_operator_precedence(.minus) > ast.binary_operator_precedence(.plus)
	assert ast.unary_operator_precedence(.exl_mark) > ast.binary_operator_precedence(.plus)
	assert ast.unary_operator_precedence(.exl_mark) == ast.unary_operator_precedence(.plus)
	assert ast.unary_operator_precedence(.exl_mark) == ast.unary_operator_precedence(.minus)
}
