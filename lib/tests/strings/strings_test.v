fn test_assign_literal() {
	s := '12345'
	assert s.len == 5
}
fn test_assign_string() {
	s := '12345'
	a := s
	assert a.len == s.len
}

fn test_assign_string_and_change_it() {
	s := '12345'
	mut a := s
	a = '123456'
	assert a.len == 6
}