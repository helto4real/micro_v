import lib.comp.gen.llvm_gen.llvm
import lib.comp.binding
import lib.comp.symbols

fn main() {
	// code := '
	// fn main() {

	// }'
	
	mut mod := llvm.new_llvm_module('main')
	op := binding.bind_binary_operator(.mul, symbols.int_symbol, symbols.int_symbol) or {panic('not expected')}
	stmts := [binding.new_bound_return_with_expr_stmt(
		binding.new_bound_binary_expr(
			binding.new_bound_literal_expr(10),
			op, 
			binding.new_bound_literal_expr(3))
		
	)]
	mod.declare_function(
		symbols.new_function_symbol(
			'main', []symbols.ParamSymbol{}, symbols.int_symbol),
		binding.new_bound_block_stmt(stmts)
	)

	mod.verify() ?
	
	mod.print_to_file('test.ll') ?
}