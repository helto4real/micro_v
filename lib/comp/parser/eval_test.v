
//TODO: Remove eval implementation and run 100% JIT
fn test_some_stuff(){}
// // module parser
// import lib.comp.binding
// import lib.comp.parser
// import lib.comp
// import lib.comp.util.source
// import lib.comp.util

// struct TestCompilationState {
// mut:
// 	vars      &binding.EvalVariables
// 	prev_comp &comp.Compilation
// }

// pub fn new_test_compilation_state() &TestCompilationState {
// 	return &TestCompilationState{
// 		vars: binding.new_eval_variables()
// 		prev_comp: &comp.Compilation(0)
// 	}
// }

// fn (mut tcs TestCompilationState) evaluate(expr string) comp.EvaluationResult {
// 	syntax_tree := parser.parse_syntax_tree(expr)

// 	if syntax_tree.log.all.len > 0 {
// 		eprintln('expression error: $expr')
// 		assert syntax_tree.log.all.len == 0
// 	}

// 	mut comp := if tcs.prev_comp == 0 { comp.create_script(&comp.Compilation(0), [syntax_tree]) } else { comp.create_script(tcs.prev_comp, [
// 			syntax_tree,
// 		]) }
// 	res := comp.evaluate(tcs.vars)
// 	tcs.prev_comp = comp
// 	return res
// }

// pub fn (mut tcs TestCompilationState) eval_int(expr string) int {
// 	res := tcs.evaluate(expr)
// 	if res.val is int {
// 		return res.val
// 	}
// 	panic('unexpected return type: $res')
// }

// pub fn (mut tcs TestCompilationState) eval_stmt(stmt string) {
// 	_ := tcs.evaluate(stmt)
// }

// pub fn (mut tcs TestCompilationState) eval_bool(expr string) bool {
// 	res := tcs.evaluate(expr)
// 	if res.val is bool {
// 		return res.val
// 	}
// 	panic('unexpected return type: $res')
// }

// pub fn (mut tcs TestCompilationState) eval_string(expr string) string {
// 	res := tcs.evaluate(expr)
// 	if res.val is string {
// 		return res.val
// 	}
// 	panic('unexpected return type: $res')
// }

// fn test_eval_basic_exprs() {
// 	mut c := new_test_compilation_state()

// 	assert c.eval_int('2+2') == 4
// 	assert c.eval_int('10+2-4') == 8
// 	// test precedene
// 	assert c.eval_int('10+8*2') == 26
// 	assert c.eval_int('10+8*2/4') == 14
// 	// test paranthes 
// 	assert c.eval_int('(10+8)*2/4') == 9
// 	assert c.eval_int('(10+8)*((2+2)*(2+3))') == 360

// 	// test unary expressions
// 	assert c.eval_bool('!true') == false
// 	assert c.eval_bool('!false') == true
// 	assert c.eval_int('-1') == -1
// 	assert c.eval_int('~1') == -2

// 	// test more operators
// 	assert c.eval_int('1 | 2') == 3
// 	assert c.eval_int('1 | 0') == 1
// 	assert c.eval_int('1 & 2') == 0
// 	assert c.eval_int('1 & 0') == 0
// 	assert c.eval_int('0 ^ 1') == 1
// 	assert c.eval_int('1 ^ 3') == 2

// 	// test boolean expressions
// 	assert c.eval_bool('true') == true
// 	assert c.eval_bool('false') == false
// 	assert c.eval_bool('true && true') == true
// 	assert c.eval_bool('true && false') == false
// 	assert c.eval_bool('false && false') == false
// 	assert c.eval_bool('false && false') == false
// 	assert c.eval_bool('true') == true
// 	assert c.eval_bool('true || false') == true
// 	assert c.eval_bool('true || true') == true
// 	assert c.eval_bool('false || true') == true
// 	assert c.eval_bool('false || false') == false

// 	// test if expressions
// 	assert c.eval_int('a:= if true {100} else {200} a') == 100
// 	assert c.eval_int('a:= if false {100} else {200} a') == 200

// 	// test lt, gt, le, ge
// 	assert c.eval_bool('10 < 11') == true
// 	assert c.eval_bool('10 <= 11') == true
// 	assert c.eval_bool('10 > 9') == true
// 	assert c.eval_bool('10 >= 9') == true
// 	assert c.eval_bool('10 <= 10') == true
// 	assert c.eval_bool('10 >= 10') == true

// 	assert c.eval_bool('10 > 11') == false
// 	assert c.eval_bool('10 >= 11') == false
// 	assert c.eval_bool('10 < 9') == false
// 	assert c.eval_bool('10 <= 9') == false
// 	// test equals and not equals operators
// 	assert c.eval_bool('1 == 1') == true
// 	assert c.eval_bool('1 != 2') == true
// 	assert c.eval_bool('true == true') == true
// 	assert c.eval_bool('false == false') == true
// 	assert c.eval_bool('false != true') == true
// 	assert c.eval_bool("'hello' == 'hello'") == true
// 	assert c.eval_bool("'Hello' == 'hello'") == false

// 	// test combo operators
// 	assert c.eval_bool('1==1 && 5==5') == true
// 	assert c.eval_bool('1!=2 && 3!=5') == true
// 	assert c.eval_bool('1==2 && 3!=5') == false
// 	assert c.eval_bool('1==2 || 3!=5') == true
// }

// fn test_eval_var_exprs() {
// 	mut c := new_test_compilation_state()

// 	c.eval_stmt('x:=4')
// 	assert c.eval_int('x+4') == 8
// 	assert c.eval_int('x+x') == 8
// 	assert c.eval_int('x-x') == 0

// 	c.eval_stmt('mut z:=4')
// 	assert c.eval_int('(z=2)+z') == 4

// 	c.eval_stmt('a:=true')
// 	c.eval_stmt('b:=true')
// 	c.eval_stmt('c:=false')
// 	assert c.eval_bool('a==b') == true
// 	assert c.eval_bool('a!=b') == false
// 	assert c.eval_bool('a!=c') == true
// 	assert c.eval_bool('a||c') == true
// 	assert c.eval_bool('a&&c') == false

// 	assert c.eval_bool('mut a:=true a = !a return a') == false
// }

// fn test_range_expr() {
// 	mut c := new_test_compilation_state()
// 	assert c.eval_string('1..10') == '1..10'
// 	assert c.eval_string('10..1') == '10..1'
// }

// fn test_loops() {
// 	mut c := new_test_compilation_state()
// 	assert c.eval_int('mut a:=10 for a > 5 {a = a-1} a') == 5
// 	assert c.eval_int('mut a:= 0 for a < 3 {a = a+1} a') == 3
// 	assert c.eval_int('mut a:= 0 for b in 0..10 {a = a + b} a') == 45

// 	assert c.eval_int('mut a:= 0 for b in 0..10 {a = a + b if b == 5 {break}} a') == 15
// 	assert c.eval_int('mut a:= 0 for b in 0..10 {if b == 5 {continue} a = a + b } return a') == 40
// 	assert c.eval_int('
		
// 			mut a:= 0 
// 			mut b:= 0
// 			for {
// 				a=a+1
// 				if a == 5 {
// 					b=a+1
// 					break
// 				}
// 			} 
// 		   b
// 		') == 6
// }

// fn test_string_expressions() {
// 	mut c := new_test_compilation_state()
// 	assert c.eval_string('"hello"') == 'hello'
// 	assert c.eval_string("'hello'") == 'hello'
// 	assert c.eval_string("'hello' + ' world'") == 'hello world'
// }

// fn test_if_else_stmt() {
// 	mut c := new_test_compilation_state()

// 	assert c.eval_int('mut a:=0 if 10==10 {a=1} return a') == 1
// 	assert c.eval_bool('mut a:=false if 11>10 {a=true} return a') == true
// 	assert c.eval_int('
// 		mut a:=0 
// 		if 10==10 {
// 			a=10
// 		} else {
// 			a=20
// 		} 
// 		return a
// 		') == 10
// 	assert c.eval_int('mut a:=0 if 10!=10 {a=10} else {a=20} return a') == 20
// 	assert c.eval_int('
// 		a:=100
// 		mut b:=200
// 		if a>b {
// 			b=1
// 		} else {
// 			b=2
// 		}
// 		return b
// 	') == 2
// }

// fn test_error_delcarations_binar_operator_type() {
// 	code := 'true[||]2'
// 	error := ' binary operator || is not defined for types bool and int.'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_delcarations_unary_operator_undefined() {
// 	code := '[+]true'
// 	error := ' unary operator + is not defined for type bool.'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_range_type_error() {
// 	code := '1..[a]'
// 	error := 'unexpected token: <name>,  expected <number>\nvariable <a> does not exist'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_delcarations_assign_different_types_error() {
// 	code := '
// 		{
// 			mut x:=10
// 			x=[true]
// 		}
// 	'
// 	error := 'cannot convert from type <bool> to <int>'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_delcarations_no_mut_assign_error() {
// 	code := '
// 		{
// 			x:=10
// 			x[=]100
// 		}
// 	'
// 	error := 'assign non mutable varable: <x>'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_delcarations_report_errors() {
// 	code := '
// 		{
// 			x:=10
// 			y:=100
// 			{
// 				x:=true
// 			}
// 			[x]:=5
// 		}
// 	'
// 	error := 'name: <x> already defined'
// 	assert_has_diagostics(code, error)
// }

// fn test_error_if_has_expr_wrong_type_report_errors() {
// 	code := '
// 		{
// 			x:=10
// 			if [x] {10}
// 		}
// 	'
// 	error := 'cannot convert from type <int> to <bool>' //
// 	assert_has_diagostics(code, error)
// }

// fn test_error_if_wrong_type_report_errors() {
// 	code := '
// 		{
// 			x:=10
// 			y:=100
// 			{
// 				x:=true
// 			}
// 			[x]:=5
// 		}
// 	'
// 	error := 'name: <x> already defined'
// 	assert_has_diagostics(code, error)
// }

// fn assert_has_diagostics(text string, diagnostic_text string) {
// 	assert_has_multi_diagostics(text, diagnostic_text, 1)
// }

// fn assert_has_multi_diagostics(text string, diagnostic_text string, nr_of_err_msg int) {
// 	vars := binding.new_eval_variables()

// 	ann_text := util.parse_annotated_text(text)

// 	syntax_tree := parser.parse_syntax_tree(ann_text.text)
// 	mut comp := comp.create_script(&comp.Compilation(0), [syntax_tree])

// 	res := comp.evaluate(vars)

// 	expected_diagnostics := util.unindent_lines(diagnostic_text)

// 	if expected_diagnostics.len != res.result.len {
// 		assert_err_info_diag(text, diagnostic_text, '', res.result)
// 		assert expected_diagnostics.len == res.result.len
// 	}

// 	for i := 0; i < expected_diagnostics.len; i++ {
// 		expected_message := expected_diagnostics[i]
// 		actual_message := res.result[i].text

// 		if expected_message != actual_message {
// 			assert_err_info(text, diagnostic_text, actual_message)
// 			println('expected diagnostics:')
// 			println(expected_diagnostics)
// 			println('actual result:')
// 			println(res.result)
// 			assert expected_message == actual_message
// 		}

// 		if i < ann_text.posns.len {
// 			actual_location := res.result[i].location
// 			actual_pos := actual_location.pos
// 			expected_pos := ann_text.posns[i]

// 			if actual_pos != expected_pos {
// 				assert_err_info(text, diagnostic_text, actual_message)
// 				assert actual_pos == expected_pos
// 			}
// 		}
// 	}
// }

// fn assert_err_info(input_rule string, expected_message string, actual_message string) {
// 	assert_err_info_diag(input_rule, expected_message, actual_message, []&source.Diagnostic{})
// }

// fn assert_err_info_diag(input_rule string, expected_message string, actual_message string, actual_diagnostics []&source.Diagnostic) {
// 	// make sure we print info so we can find the method that is faulty	
// 	eprintln('input rule:')
// 	eprintln(input_rule)
// 	eprintln('expected message:')
// 	eprintln(expected_message)
// 	eprintln('actual message:')
// 	eprintln(actual_message)
// 	if actual_diagnostics.len > 0 {
// 		eprintln('actual diagnistics:')
// 		eprintln(actual_diagnostics)
// 	}
// }
