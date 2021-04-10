module llvm

import os

import lib.comp.util.source
import lib.comp.binding
import lib.comp.gen.llvm.core

struct LlvmGen {
mut:
	log                   &source.Diagnostics
	mod                   core.Module
	program               &binding.BoundProgram = 0
	binary_full_path      string
	result_file_full_path string
}

pub fn new_llvm_generator() LlvmGen {
	return LlvmGen{
		log: source.new_diagonistics()
		mod: core.new_llvm_module('program')
	}
}

pub fn (mut l LlvmGen) generate(binary_full_path string, program &binding.BoundProgram) &source.Diagnostics {
	l.program = program
	l.binary_full_path = binary_full_path

	binary_directory := os.dir(binary_full_path)
	binary_name := os.file_name(binary_full_path)
	l.result_file_full_path = os.join_path(binary_directory, '${binary_name}.ll')

	// Generate code
	l.generate_code(false)

	if l.log.all.len > 0 {
		return l.log
	}
	// Compile generated code
	l.compile_code()

	l.mod.free()
	return l.log
}

pub fn (mut l LlvmGen) run(program &binding.BoundProgram) &source.Diagnostics {
	l.program = program
	l.result_file_full_path = 'generated.ll'
	l.generate_code(false)
	l.mod.run_main()
	l.mod.free()
	return l.log
}

pub fn (mut l LlvmGen) run_tests(program &binding.BoundProgram) &source.Diagnostics {
	l.program = program
	l.result_file_full_path = 'generated.ll'
	l.generate_code(true)
	res := l.mod.run_tests()
	if !res {
		l.log.error_msg('test failed')
	} 

	l.mod.free()
	return l.log
}

fn (mut l LlvmGen) generate_code(is_test bool) {
	l.mod.generate_module(l.program, is_test)
	l.mod.optimize()
	l.mod.print_to_file(l.result_file_full_path) or { panic('unexpected error cannot print to file') }
	l.mod.verify() or { panic('unexpected error generating llvm code') }
}

fn (mut l LlvmGen) compile_code() {
	binary_directory := os.dir(l.binary_full_path)
	binary_name := os.file_name(l.binary_full_path)
	compile_command := 'llc -O3 $l.result_file_full_path'
	s_file := os.join_path(binary_directory, '${binary_name}.s')
	gen_executable_command := 'clang -O3 -o $l.binary_full_path $s_file'
	res := os.execute(compile_command)
	if res.exit_code != 0 {
		l.log.error_msg(res.output)
	}
	res_exe := os.execute(gen_executable_command)
	if res_exe.exit_code != 0 {
		l.log.error_msg(res.output)
	}
}
