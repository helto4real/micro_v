struct AnotherTestStruct {
	a_int    int
	a_string string
}

fn (t AnotherTestStruct) sum(n int) int {
	return t.a_int + n
}

fn (t &AnotherTestStruct) ref_sum(n int) int {
	return t.a_int + n
}

fn (mut t AnotherTestStruct) add(n int) {
	t.a_int = t.a_int + n
}

fn test_struct_fn() {
	ts := AnotherTestStruct{
		a_int: 100
		a_string: 'hello'
	}
	res := ts.sum(10)
	assert res == 110

	res2 := ts.ref_sum(20)
	assert res2 == 120

	ts.add(100)
	assert ts.a_int == 200
}
