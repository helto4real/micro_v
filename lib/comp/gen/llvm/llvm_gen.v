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
	program &binding.BoundProgram = 0
	binary_full_path string
	result_file_full_path string
}

pub fn new_llvm_generator() LlvmGen {
	return LlvmGen{
		log: source.new_diagonistics()
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
	return l.log
}


fn (mut l LlvmGen) generate_code() {

	builder := core.new_llvm_builder()
	mut mod := core.new_llvm_module('program', builder)
	mod.add_standard_funcs()
	for func in l.program.func_symbols {
		body := l.program.func_bodies[func.id]
		lowered_body := binding.lower(body)
		mod.declare_function(
			symbols.new_function_symbol(
			func.name, []symbols.ParamSymbol{}, symbols.int_symbol),
			lowered_body 
		)
	}

	mod.print_to_file(l.result_file_full_path) or {panic('ERROR another mother fucker')}
	mod.verify() or {panic('ERROR mother fucker')}
	// // write main func
	// main_func := l.program.main_func
	// main_body := l.program.func_bodies[main_func.id]
	// write_symbol(cw, main_func)
	// cw.write_space()
	// write_node(cw, binding.BoundStmt(main_body))

	// // write code to file

	// os.write_file(l.gofile_full_path, cw.str()) or {
	// 	l.log.error_msg(err.msg)
	// }

}

fn (mut l LlvmGen) compile_code() {
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