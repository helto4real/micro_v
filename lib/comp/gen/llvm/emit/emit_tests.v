module emit

import term

pub fn (mut em EmitModule) run_tests() bool {
	em.init_execution_engine() or { panic('error init execution enging : $err.msg') }
	if em.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	mut test_funcs := []FunctionDecl{}
	for func in em.funcs {
		if func.name.starts_with('test_') {
			test_funcs << func
		}
	}

	// test_funcs.sort_with_compare(compare_function_by_file_and_name)

	// run main to be sure it is jit compiled
	em.exec_engine.run_function(em.main_func_val)

	mut nr_of_tests := 0
	mut nr_of_errors := 0
	mut current_file_has_errors := false
	mut current_file := ''
	mut total_nr_of_test_files := 0

	for func in test_funcs {
		if func.func.location.source.filename != current_file {
			total_nr_of_test_files++
			current_file = func.func.location.source.filename
		}
	}
	current_file = ''
	println('------------------------------ test ------------------------------')
	for func in test_funcs {
		if func.func.location.source.filename != current_file {
			if current_file.len > 0 {
				print_result(current_file, !current_file_has_errors, nr_of_tests, total_nr_of_test_files)
			}
			current_file = func.func.location.source.filename
			current_file_has_errors = false
			nr_of_tests++
		}
		test_res := em.exec_engine.run_function(func.val)
		int_res := i64(test_res.int(true))
		if int_res == 0 {
		} else {
			current_file_has_errors = true
			nr_of_errors++
		}
	}
	print_result(current_file, !current_file_has_errors, nr_of_tests, total_nr_of_test_files)

	println('------------------------------------------------------------------')
	return nr_of_errors == 0
}

fn print_result(filename string, is_ok bool, test_nr int, total_nr_of_tests int) {
	print('   ')
	if is_ok {
		print(term.green(' OK   '))
	} else {
		print(term.fail_message('FAIL'))
	}
	print(' [')
	total_nr_of_digits_total := nr_of_digits(total_nr_of_tests)
	total_nr_of_digits_test_nr := nr_of_digits(test_nr)
	leading_zeros := total_nr_of_digits_total - total_nr_of_digits_test_nr
	if leading_zeros > 0 {
		print('0'.repeat(leading_zeros))
	}
	print('$test_nr/$total_nr_of_tests]  ')
	println(filename)
}

fn nr_of_digits(n int) int {
	mut total := 0
	for i := 1; i <= n; i *= 10 {
		total++
	}
	return total
}

// fn compare_function_by_file_and_name(a &FunctionDecl, b &FunctionDecl) int {
// 	println('COMPARE : ${voidptr(a.func)}, ${voidptr(b.func)}')
// 	if a.func.location.source.filename == b.func.location.source.filename {
// 		if a.func.name < b.func.name {
// 			return -1
// 		} else {
// 			return 1
// 		}
// 	}

// 	if a.func.location.source.filename < b.func.location.source.filename {
// 		return -1
// 	}
// 	return 1
// }
