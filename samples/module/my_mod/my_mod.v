module my_mod 

struct TestStruct {
	my_int int
}

fn (t TestStruct) a_func_on_test_struct() {
	println('hello')
}

fn a_cool_module(i int) int {
	return i
}

