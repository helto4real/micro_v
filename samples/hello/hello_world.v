// fn main() {
// 	println('hello world!')
// }

fn no_mut_or_ref(x int) {
	assert x == 10
}

fn mutable_function_param_with_assert(mut x int) {
	no_mut_or_ref(x)
}

fn main() {
	mut x:= 100
	mutable_function_param_with_assert(mut x)
	assert x == 10
}