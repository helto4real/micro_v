struct Test{
	member int
	another string
}

fn do_test(test Test) {
	println(test.another)
}

fn main() {
	mut t := Test {
		member: 10
		another: 'hello'
	}

	t.another = 'hello world'
	do_test(t)

}

