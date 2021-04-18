// struct MyStruct {
// 	an_int int
// 	x string
// }

fn test(mut x int) {
	x = 10
}

// fn edit_struct(mut mss MyStruct) {
// 	// a:= string( mss.an_int  )
// 	// println('tomas')
// 	// println(mss.x)
// 	mss.x = 'another string'
// }


fn main() {
	// mut ms := MyStruct{
	// 	an_int: 100
	// 	x: 'hello baby'
	// }
	// edit_struct(mut ms)
	// println(ms.x)
	mut a := 1
	test(mut a)
	println(string(a))
}