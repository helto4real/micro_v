struct AnotherTestStruct {
	a_int    int
}

fn (t AnotherTestStruct) sum(n int) int {
	return t.a_int + n
}

fn (t &AnotherTestStruct) ref_sum(n int) int {
	return t.a_int + n
}

fn (t AnotherTestStruct) sum_ref_param(n &int) int {
	return t.a_int + n
}

fn (t &AnotherTestStruct) ref_sum_ref_param(n &int) int {
	return t.a_int + n
}

fn (mut t AnotherTestStruct) add(n int) {
	t.a_int = t.a_int + n
}

fn main() {
	ts := AnotherTestStruct{
		a_int: 100
	}
	res := ts.sum(10)
	println(string(res))

	res2 := ts.ref_sum(20)
	println(string(res2))

	val := 30
	res3 := ts.sum_ref_param(&val)
	println(string(res3))

	val2 := 40
	res4 := ts.ref_sum_ref_param(&val2)
	println(string(res4))

	mut mts := AnotherTestStruct{
		a_int: 100
	}
	mts.add(100)
	println(string(mts.a_int))
}