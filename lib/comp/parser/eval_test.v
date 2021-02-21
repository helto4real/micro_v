// module parser
import lib.comp.binding
import lib.comp.parser
import lib.comp


struct TestCompilationState {
mut:
	vars &binding.EvalVariables
	prev_comp &comp.Compilation
}

pub fn new_test_compilation_state() &TestCompilationState {
	return &TestCompilationState {
		vars: binding.new_eval_variables()
		prev_comp: &comp.Compilation(0)
	}
}

fn (mut tcs TestCompilationState) evaluate(expr string) comp.EvaluationResult {
	syntax_tree := parser.parse_syntax_tree(expr)

	if syntax_tree.log.all.len > 0 {
		eprintln('expression error: $expr')
		assert syntax_tree.log.all.len == 0
	}

	mut comp := if tcs.prev_comp == 0 {
		comp.new_compilation(syntax_tree)
	} else {
		tcs.prev_comp.continue_with(syntax_tree)
	}
	res := comp.evaluate(tcs.vars)
	tcs.prev_comp = comp
	return res
}

pub fn (mut tcs TestCompilationState) eval_int(expr string) int {
	res := tcs.evaluate(expr)
	if res.val is int {
		return res.val
	}
	panic('unexpected return type: $res')
}

pub fn (mut tcs TestCompilationState) eval_stmt(stmt string) {
	res := tcs.evaluate(stmt)
}

pub fn (mut tcs TestCompilationState) eval_bool(expr string) bool {
	res := tcs.evaluate(expr)
	if res.val is bool {
		return res.val
	}
	panic('unexpected return type: $res')
}

fn test_eval_basic_exprs() {
	mut c := new_test_compilation_state()

	assert c.eval_int('2+2') == 4
	assert c.eval_int('10+2-4') == 8
	// test precedene
	assert c.eval_int('10+8*2') == 26
	assert c.eval_int('10+8*2/4') == 14
	// test paranthes 
	assert c.eval_int('(10+8)*2/4') == 9
	assert c.eval_int('(10+8)*((2+2)*(2+3))') == 360

	// test unary expressions
	assert c.eval_int('-1') == -1

	// test boolean expressions
	assert c.eval_bool('true') == true
	assert c.eval_bool('false') == false
	assert c.eval_bool('true && true') == true
	assert c.eval_bool('true && false') == false
	assert c.eval_bool('false && false') == false
	assert c.eval_bool('false && false') == false
	assert c.eval_bool('true') == true
	assert c.eval_bool('true || false') == true
	assert c.eval_bool('true || true') == true
	assert c.eval_bool('false || true') == true
	assert c.eval_bool('false || false') == false

	// test equals and not equals operators
	assert c.eval_bool('1 == 1') == true
	assert c.eval_bool('1 != 2') == true
	assert c.eval_bool('true == true') == true
	assert c.eval_bool('false == false') == true
	assert c.eval_bool('false != true') == true

	// test combo operators
	assert c.eval_bool('1==1 && 5==5') == true
	assert c.eval_bool('1!=2 && 3!=5') == true
	assert c.eval_bool('1==2 && 3!=5') == false
	assert c.eval_bool('1==2 || 3!=5') == true
}

fn test_eval_var_exprs() {
	mut c := new_test_compilation_state()

	c.eval_stmt('x:=4') 
	assert c.eval_int('x+4') == 8
	assert c.eval_int('x+x') == 8
	assert c.eval_int('x-x') == 0

	c.eval_stmt('mut z:=4') 
	assert c.eval_int('(z=2)+z') == 4
	
	c.eval_stmt('a:=true')
	c.eval_stmt('b:=true')
	c.eval_stmt('c:=false')
	assert c.eval_bool('a==b') == true
	assert c.eval_bool('a!=b') == false
	assert c.eval_bool('a!=c') == true
	assert c.eval_bool('a||c') == true
	assert c.eval_bool('a&&c') == false
}

