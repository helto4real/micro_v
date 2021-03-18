// testing MV different statemetns and expressions

fn not(b bool) bool {
	return !b
}
mut x := true
if not(x) {
	println('not true')
} else {
	println('true')
}
x = !x
if not(x) {
	println('not true')
} else {
	println('true')
}