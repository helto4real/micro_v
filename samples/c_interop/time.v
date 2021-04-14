struct C.in_addr {
	s_addr int
}

struct C.sockaddr_in {
	sin_family int
	sin_port   int
	sin_addr   C.in_addr
}

struct C.some_ptr {}
// struct C.timespec {
// 	tv_sec  i64
// 	tv_nsec i64
// }

fn main() {
	// x := C.timespec{}
	y := C.sockaddr_in {}
	x := &C.some_ptr{}
}