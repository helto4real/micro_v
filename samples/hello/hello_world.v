struct Test{
	member int
	big i64
	another string
}

fn do_test(test Test) {
	println(test.another)
	assert true
	println(test.another)
}

fn main() {
	mut t := Test {
		member: 10
		another: 'hello'
	}
	println('before exit')
	do_test(t)
	println('after exit')

}

