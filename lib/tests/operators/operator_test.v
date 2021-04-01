fn test_basic_operators() {
	assert 1 + 1 == 2
	assert 10 * 11 == 110
	assert (50 + 50) * 10 == 1000
	assert 10 / 2 == 5
	assert 3 / 2 == 1
}

fn test_basic_logical_operators() {
	assert true == true
	assert false == false
	assert !false == true
	assert !true == false

	assert !(1 == 1) == false
}
