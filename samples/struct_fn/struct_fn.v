struct TestStruct {
	an_int int
}

fn (t TestStruct) add_to_int(n int) int {
	// t.an_int = 5
	return t.an_int + n
}

fn main() {
	ts := TestStruct{
		an_int: 10
	}

	a := ts.add_to_int(5)
	println(string(a))
}
