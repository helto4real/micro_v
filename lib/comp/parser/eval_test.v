module parser

fn test_eval_basic_expressions() {
	assert eval('2+2') == 4
	assert eval('10+2-4') == 8
	// test precedence
	assert eval('10+8*2') == 26
	assert eval('10+8*2/4') == 14
	// test parantheses
	assert eval('(10+8)*2/4') == 9
	assert eval('(10+8)*((2+2)*(2+3))') == 360

	// test unary expressions
	assert eval('-1') == -1

}

fn eval(expr string) int {
	syntax_tree := parser.parse_syntax_tree(expr)
	assert syntax_tree.errors.len == 0
	mut ev := parser.new_evaluator(syntax_tree.root)
	res := ev.evaluate() or {panic(err)}
	return res
}