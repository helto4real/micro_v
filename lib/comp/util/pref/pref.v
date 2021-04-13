module pref

// CompPref contains the compiler preferences
pub struct CompPref {
pub:
	is_prod  bool   // true to compile with optimizations
	print_ll bool   // true to print the module after compile or run
	output   string // path to output file
}

pub fn new_comp_pref(is_prod bool, print_ll bool, output string) CompPref {
	return CompPref{
		is_prod: is_prod
		print_ll: print_ll
		output: output
	}
}
