module gen

import lib.comp.util.source
import lib.comp.util.pref
import lib.comp.binding

pub interface Generator {
	generate(pref pref.CompPref, program &binding.BoundProgram) &source.Diagnostics
	run(program &binding.BoundProgram, pref pref.CompPref) &source.Diagnostics
	run_tests(program &binding.BoundProgram) &source.Diagnostics
}
