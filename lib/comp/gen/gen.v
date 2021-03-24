module gen

import lib.comp.util.source
import lib.comp.binding

pub interface Generator {
	generate(filename string, program &binding.BoundProgram) &source.Diagnostics
	run(program &binding.BoundProgram) &source.Diagnostics
}