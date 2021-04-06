fn test_basic_fixed_value_array() {
	arr := [1,2,3,4]!
	
	for i in 1..5 {
		assert arr[i-1] == i
	}
}