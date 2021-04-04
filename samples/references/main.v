struct MyStruct {
	an_int int
	x string
}

fn test(mut x int) {
	x = 10
}

fn edit_struct(mut mss MyStruct) {
	// a:= string( mss.an_int  )
	// println('tomas')
	// println(mss.x)
	mss.x = 'another string'
}


fn main() {
	ms := MyStruct{
		an_int: 100
		x: 'hello baby'
	}
	edit_struct(ms)
	println(ms.x)
	mut a := 1
	test(a)
}