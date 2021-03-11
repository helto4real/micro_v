fn sum(n int) int {
	mut i := 10
	mut res := 0
	for {
		if i == 0 {
			break
		}
		res = res + i
		i = i - 1
	}
}
