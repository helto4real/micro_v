module golang

import os

import lib.comp.util.source
import lib.comp.binding
import lib.comp.io

struct GolangGen {
mut:
	log  &source.Diagnostics
	program &binding.BoundProgram = 0
	filename string
}

pub fn new_golang_generator() GolangGen {
	return GolangGen{
		log: source.new_diagonistics()
	}
}
pub fn (mut g GolangGen) generate(filename string, program &binding.BoundProgram) &source.Diagnostics {
	g.program = program
	g.filename = filename

	// Generate code
	g.generate_code()

	if g.log.all.len > 0 {
		return g.log
	}
	// Compile generated code
	g.compile_code()
	return g.log
}

fn (mut g GolangGen) generate_code() {
	mut cw := io.new_general_code_writer()

	main_template := os.read_file('lib/comp/gen/golang/templates/main.go') or {
		g.log.error_msg(err.msg) 
		return
	}
	cw.writeln(main_template)
	
	for func in g.program.func_symbols {
		if func.name != 'main' {
			body := g.program.func_bodies[func.id]
			write_symbol(cw, func)
			cw.write_space()
			write_node(cw, binding.BoundStmt(body))
		}
	}

	// write main func
	main_func := g.program.main_func
	main_body := g.program.func_bodies[main_func.id]
	write_symbol(cw, main_func)
	cw.write_space()
	write_node(cw, binding.BoundStmt(main_body))

	// write code to file
	os.write_file('tmp/main.go', cw.str()) or {
		g.log.error_msg(err.msg)
	}

}

fn (mut g GolangGen) compile_code() {
	res := os.execute('go build -o tmp/main tmp/main.go')
	if res.exit_code != 0 {
		g.log.error_msg(res.output)
	}
}