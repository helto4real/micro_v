module llvm

import os

import lib.comp.util.source
import lib.comp.binding
// import lib.comp.io
import lib.comp.gen.llvm.core
import lib.comp.symbols

struct LlvmGen {
mut:
	log  &source.Diagnostics
	mod core.Module
	program &binding.BoundProgram = 0
	binary_full_path string
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
	l.generate_code()

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
	// l.mod.init_jit_execution_engine() or {
	// 	l.log.error_msg('$err.msg')
	// 	return l.log
	// }
	// Generate code
	l.generate_code()
	l.mod.run_main()
	l.mod.free()
	return l.log
}


fn (mut l LlvmGen) generate_code() {

	for func in l.program.func_symbols {
		body := l.program.func_bodies[func.id]
		lowered_body := binding.lower(body)
		l.mod.declare_function(
			symbols.new_function_symbol(
			func.name, []symbols.ParamSymbol{}, symbols.int_symbol),
			lowered_body 
		)
	}

	l.mod.verify() or {panic('ERROR mother fucker')}
	
}

fn (mut l LlvmGen) compile_code() {
	l.mod.print_to_file(l.result_file_full_path) or {panic('ERROR another mother fucker')}
	binary_directory := os.dir(l.binary_full_path)
	binary_name := os.file_name(l.binary_full_path)
	compile_command := 'llc -O3 ${l.result_file_full_path}'
	s_file := os.join_path(binary_directory, '${binary_name}.s')
	gen_executable_command := 'clang -O3 -o ${l.binary_full_path} ${s_file}'
	res := os.execute(compile_command)
	if res.exit_code != 0 {
		l.log.error_msg(res.output)
	}
	res_exe := os.execute(gen_executable_command)
	if res_exe.exit_code != 0 {
		l.log.error_msg(res.output)
	}
}