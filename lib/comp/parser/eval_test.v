// module parser
import lib.comp.binding
import lib.comp.parser
import lib.comp

fn test_eval_basic_expressions() {
	assert eval_int('2+2') == 4
	assert eval_int('10+2-4') == 8
	// test precedence
	assert eval_int('10+8*2') == 26
	assert eval_int('10+8*2/4') == 14
	// test parantheses 
	assert eval_int('(10+8)*2/4') == 9
	assert eval_int('(10+8)*((2+2)*(2+3))') == 360

	// test unary expressions
	assert eval_int('-1') == -1

	// test boolean expressions
	assert eval_bool('true') == true
	assert eval_bool('false') == false
	assert eval_bool('true && true') == true
	assert eval_bool('true && false') == false
	assert eval_bool('false && false') == false
	assert eval_bool('false && false') == false
	assert eval_bool('true') == true
	assert eval_bool('true || false') == true
	assert eval_bool('true || true') == true
	assert eval_bool('false || true') == true
	assert eval_bool('false || false') == false

	// test equals and not equals operators
	assert eval_bool('1 == 1') == true
	assert eval_bool('1 != 2') == true
	assert eval_bool('true == true') == true
	assert eval_bool('false == false') == true
	assert eval_bool('false != true') == true

	// test combo operators
	assert eval_bool('1==1 && 5==5') == true
	assert eval_bool('1!=2 && 3!=5') == true
	assert eval_bool('1==2 && 3!=5') == false
	assert eval_bool('1==2 || 3!=5') == true
	
}

fn eval_int(expr string) int {
	syntax_tree := parser.parse_syntax_tree(expr)
	assert syntax_tree.log.all.len == 0

	mut binder := binding.new_binder()
	bounded_syntax := binder.bind_expr(syntax_tree.root)
	assert binder.log.all.len == 0

	mut ev := comp.new_evaluator(bounded_syntax)
	res := ev.evaluate() or {panic(err)}
	if res is int {
		return res
	}
	panic('unexpected return type: $res')
}

fn eval_bool(expr string) bool {
	syntax_tree := parser.parse_syntax_tree(expr)
	assert syntax_tree.log.all.len == 0

	mut binder := binding.new_binder()
	bounded_syntax := binder.bind_expr(syntax_tree.root)
	assert binder.log.all.len == 0

	mut ev := comp.new_evaluator(bounded_syntax)
	res := ev.evaluate() or {panic(err)}
	if res is bool {
		return res
	}
	panic('unexpected return type: $res')
}