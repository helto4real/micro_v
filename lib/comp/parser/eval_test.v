// module parser
import lib.comp.binding
import lib.comp.parser
import lib.comp

fn test_eval_basic_exprs() {
	mut t := binding.new_symbol_table()

	assert eval_int(t, '2+2') == 4
	assert eval_int(t, '10+2-4') == 8
	// test precedence
	assert eval_int(t, '10+8*2') == 26
	assert eval_int(t, '10+8*2/4') == 14
	// test parantheses 
	assert eval_int(t, '(10+8)*2/4') == 9
	assert eval_int(t, '(10+8)*((2+2)*(2+3))') == 360

	// test unary expressions
	assert eval_int(t, '-1') == -1

	// test boolean expressions
	assert eval_bool(t, 'true') == true
	assert eval_bool(t, 'false') == false
	assert eval_bool(t, 'true && true') == true
	assert eval_bool(t, 'true && false') == false
	assert eval_bool(t, 'false && false') == false
	assert eval_bool(t, 'false && false') == false
	assert eval_bool(t, 'true') == true
	assert eval_bool(t, 'true || false') == true
	assert eval_bool(t, 'true || true') == true
	assert eval_bool(t, 'false || true') == true
	assert eval_bool(t, 'false || false') == false

	// test equals and not equals operators
	assert eval_bool(t, '1 == 1') == true
	assert eval_bool(t, '1 != 2') == true
	assert eval_bool(t, 'true == true') == true
	assert eval_bool(t, 'false == false') == true
	assert eval_bool(t, 'false != true') == true

	// test combo operators
	assert eval_bool(t, '1==1 && 5==5') == true
	assert eval_bool(t, '1!=2 && 3!=5') == true
	assert eval_bool(t, '1==2 && 3!=5') == false
	assert eval_bool(t, '1==2 || 3!=5') == true
}

fn test_eval_var_exprs() {
	mut t := binding.new_symbol_table()

	assert eval_int(t, 'x:=4') == 4
	assert eval_int(t, 'x+4') == 8
	assert eval_int(t, 'x+x') == 8
	assert eval_int(t, 'x-x') == 0

	assert eval_int(t, 'mut z:=4') == 4
	assert eval_int(t, '(z=2)+z') == 4
	
	assert eval_bool(t, 'a:=true') == true
	assert eval_bool(t, 'b:=true') == true
	assert eval_bool(t, 'c:=false') == false
	assert eval_bool(t, 'a==b') == true
	assert eval_bool(t, 'a!=b') == false
	assert eval_bool(t, 'a!=c') == true
	assert eval_bool(t, 'a||c') == true
	assert eval_bool(t, 'a&&c') == false
}

fn eval_int(table &binding.SymbolTable, expr string) int {
	syntax_tree := parser.parse_syntax_tree(expr)
	assert syntax_tree.log.all.len == 0

	mut binder := binding.new_binder(table)
	bounded_syntax := binder.bind_expr(syntax_tree.root)
	assert binder.log.all.len == 0

	mut ev := comp.new_evaluator(bounded_syntax, table)
	res := ev.evaluate() or { panic(err) }
	if res is int {
		return res
	}
	panic('unexpected return type: $res')
}

fn eval_bool(table &binding.SymbolTable, expr string) bool {
	syntax_tree := parser.parse_syntax_tree(expr)
	if syntax_tree.log.all.len > 0 {
		eprintln('expression error: $expr')
		assert syntax_tree.log.all.len == 0
	}
	
	mut binder := binding.new_binder(table)
	bounded_syntax := binder.bind_expr(syntax_tree.root)
	assert binder.log.all.len == 0

	mut ev := comp.new_evaluator(bounded_syntax, table)
	res := ev.evaluate() or { panic(err) }
	if res is bool {
		return res
	}
	panic('unexpected return type: $res')
}
