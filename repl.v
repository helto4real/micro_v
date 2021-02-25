
struct TestStruct {
	test_bool bool
}

fn (t TestStruct) some_func() int {
	return 0
}
type Sum = TestStruct | int
fn main() {
	x := TestStruct {
		
	}
	$for z in Sum.methods {
		println(z)

	}
}