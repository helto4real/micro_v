struct Test{
	member int
	another string
}

fn do_test(t Test) {
	
}

fn main() {
	mut t := Test {
		member: 100
		another: 'hello'
	}
	t.another = t.member
	// t.member = 200
	// println()
	do_test(t)
	// println('hello world!')
}

