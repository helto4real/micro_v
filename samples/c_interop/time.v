
struct Time {
	year        int
	month       int
	day         int
	hour        int
	minute      int
	second      int
	microsecond int
	unix        i64
}
struct C.tm {
	tm_sec   int
	tm_min   int
	tm_hour  int
	tm_mday  int
	tm_mon   int
	tm_year  int
	tm_wday  int
	tm_yday  int
	tm_isdst int
}

struct C.timespec {
	tv_sec  i64
	tv_nsec i64
}

fn C.time(t &i64) i64

fn C.localtime(t &i64) &C.tm

fn main() {
	time_t := i64(0)
	C.time(&time_t)
	t := C.localtime(&time_t)
	println(string(t.tm_year))

}