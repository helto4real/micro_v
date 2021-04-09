struct String {
	str char
	len int   

	is_lit int
}

fn vstrlen(s &byte) int {
	return C.strlen(&char(s))
}