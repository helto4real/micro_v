struct TestStruct {
	i int
	s string
}

// fn mutable_struct_function_param(mut t TestStruct) {
// 	t.i = 200
// }


fn mutable_function_param(mut x int) {
	x = 10
}

// fn no_mut_or_ref(x int) {
// 	assert x == 10
// }
// fn no_mut_but_ref(x &int) {
// 	assert x == 10
// }
// fn mutable_function_param_with_assert(mut x int) {
// 	x = 10
// 	assert x == 10
// 	no_mut_or_ref(x)
// 	no_mut_but_ref(x)
// }

fn test_mutable_param() {
	mut x:= 100
	mutable_function_param(mut x)
}
// fn test_what_ever() {
// 	assert true
// }
// fn test_anything() {
// 	assert true
// }
// fn test_mutable_struct_param() {
// 	ts := TestStruct{
// 		i: 100
// 		s: 'word'
// 	}
// 	mutable_struct_function_param(mut ts)
// 	assert ts.i == 200
	
// 	mut x := TestStruct{
// 		i: 100
// 		s: 'word'
// 	}
// 	x.i = 300
// 	mutable_struct_function_param(mut x)
// 	assert x.i == 200
// 	// todo test string when compare string works
// }



// fn sum(x &int, y int, mut res int) {
// 	res = x + y
// }

// fn test_sum_with_ref() {
// 	a := 1
// 	b := 2
// 	mut res := 0
// 	sum(a, b, mut res)
// 	assert res == 3
// 	sum(10, 20, mut res)
// 	assert res == 30
// }

fn main() {
	// assign_literal()
	// assign_string()
	// assign_string_and_change_it()
	test_mutable_param()
	// test_sum_with_ref()
}

