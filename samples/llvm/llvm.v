fn main() {
	// for x in 0..5 {
	// 	println('hello')
	// }

	mut i := 5
	for {
		if i == 0 {
			break
		}
		println('hello again')
		i = i - 1
	}
}