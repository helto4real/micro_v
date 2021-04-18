module llvm

import os
import lib.comp.util.source
import lib.comp.util.pref
import lib.comp.binding
// import lib.comp.gen.llvm.core
import lib.comp.gen.llvm.emit

struct LlvmGen {
mut:
	log                   &source.Diagnostics
	mod                   &emit.EmitModule
	pref                  pref.CompPref
	program               &binding.BoundProgram = 0
	result_file_full_path string
	optimize_jit          bool // true run optimize passes for JIT
	optimize_aheadot      bool // true run optimize passes on ahead of time compile
}

pub fn new_llvm_generator() LlvmGen {
	return LlvmGen{
		log: source.new_diagonistics()
		mod: emit.new_emit_module('program')
	}
}

pub fn (mut l LlvmGen) generate(pref pref.CompPref, program &binding.BoundProgram) &source.Diagnostics {
	l.program = program
	l.pref = pref
	binary_directory := os.dir(pref.output)
	binary_name := os.file_name(pref.output)
	l.result_file_full_path = os.join_path(binary_directory, '${binary_name}.bc')
	l.optimize_aheadot = true // only optimize ahead of time
	// Generate code
	l.generate_code(false)

	if l.log.all.len > 0 {
		return l.log
	}
	// Compile generated code
	l.compile_code()

	l.mod.dispose()
	return l.log
}

pub fn (mut l LlvmGen) run(program &binding.BoundProgram, pref pref.CompPref) &source.Diagnostics {
	l.program = program
	l.pref = pref
	l.result_file_full_path = 'generated.ll'
	l.generate_code(false)
	l.mod.run_main()
	l.mod.dispose()
	return l.log
}

pub fn (mut l LlvmGen) run_tests(program &binding.BoundProgram, pref pref.CompPref) &source.Diagnostics {
	l.program = program
	l.pref = pref
	l.result_file_full_path = 'generated.ll'
	l.generate_code(true)
	res := l.mod.run_tests()
	if !res {
		l.log.error_msg('test failed')
	}

	l.mod.dispose()
	return l.log
}

fn (mut l LlvmGen) generate_code(is_test bool) {
	l.mod.generate_module(l.program, is_test)
	if l.optimize_aheadot && l.pref.is_prod {
		l.mod.optimize()
	}
	if l.pref.print_ll {
		l.mod.print_to_file('${l.result_file_full_path}.ll') or {
			panic('unexpected error cannot print to file')
		}
	}
	l.mod.verify() or { panic('unexpected error generating llvm code') }
}

fn (mut l LlvmGen) compile_code() {
	// generate the bitcode file
	l.mod.write_to_file(l.result_file_full_path) or {
		panic('unexpected error cannot write to file')
	}
	binary_directory := os.dir(l.pref.output)
	binary_name := os.file_name(l.pref.output)
	optimize := if l.pref.is_prod { '-O2' } else { '-O0' }
	compile_command := 'llc $optimize $l.result_file_full_path'
	s_file := os.join_path(binary_directory, '${binary_name}.s')
	gen_executable_command := 'clang $optimize -o $l.pref.output $s_file'
	res := os.execute(compile_command)
	if res.exit_code != 0 {
		l.log.error_msg(res.output)
	}
	res_exe := os.execute(gen_executable_command)
	if res_exe.exit_code != 0 {
		l.log.error_msg(res.output)
	}
}
