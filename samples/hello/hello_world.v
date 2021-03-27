struct Test{
	member int
	another string
}

fn do_test(test Test) {
	println(test.another)
}

fn main() {
	mut t := Test {
		member: 100
		another: 'hello'
	}

	do_test(t)

}

