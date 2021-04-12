import my_mod

fn main() {
	a := my_mod.a_cool_module(10)
	println(string(a))

	t := my_mod.TestStruct {
		my_int: 10
	}
	t.a_func_on_test_struct()
}