struct TestStruct {
	i int
	s string
}

fn mutable_struct_function_param(mut t TestStruct) {
	t.i = 200
}


fn mutable_function_param(mut x int) {
	x = 10
}

fn no_mut_or_ref(x int) {
	assert x == 10
}
fn no_mut_but_ref(x &int) {
	assert x == 10
}
fn mutable_function_param_with_assert(mut x int) {
	x = 10
	assert x == 10
	no_mut_or_ref(x)
	no_mut_but_ref(x)
}

fn test_mutable_param() {
	x:= 100
	mutable_function_param(x)
	assert x == 10
}
fn test_what_ever() {
	assert true
}
fn test_anything() {
	assert true
}
fn test_mutable_struct_param() {
	ts := TestStruct{
		i: 100
		s: 'word'
	}
	mutable_struct_function_param(ts)
	assert ts.i == 200

	// todo test string when compare string works
}

fn test_mutable_with_operators() {
	mut a := 1
	mut b := 2
	assert a + b == 3
}

fn test_call_constant_to_mutable_function() {
	// nothing to assert, wa
	mutable_function_param_with_assert(10)
}