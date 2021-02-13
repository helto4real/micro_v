module ast
import lib.comp.token

fn test_iterator_binary_operator_expression() {
	left := new_number_expression( token.Token{kind: .number lit: '100'}, 100 )
	op_token := token.Token{kind: .plus}
	right := new_number_expression( token.Token{kind: .number lit: '200'}, 200 )
	binexpr := new_binary_expression(left, op_token, right)

	mut x := []AstNode{}
	for expr in binexpr {
		x << expr
	}	

	assert x.len == 3 
	first := x[0]
	second := x[1]
	third := x[2]

	match first {
		Expression {
			if first is NumberExp {assert first.tok.lit == '100'} else {assert false}
		} 
		else {
			assert false
		}
	}

	match second {
		token.Token {
			assert second.kind == .plus
		} 
		else {
			assert false
		}
	}

	match third {
		Expression {
			if third is NumberExp {assert third.tok.lit == '200'} else {assert false}
		} 
		else {
			assert false
		}
	}
}

fn test_iterator_number_expression() {
	nr_expr := new_number_expression( token.Token{kind: .number lit: '100'}, 100 )
	mut x := []AstNode{}
	for expr in nr_expr {
		x << expr
	}
	assert x.len == 1

	first := x[0] as token.Token 
	assert first.lit == '100'
}