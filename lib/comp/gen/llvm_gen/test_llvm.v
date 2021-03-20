import lib.comp.gen.llvm_gen.llvm
import lib.comp.binding
import lib.comp.symbols

fn main() {
	builder := llvm.new_llvm_builder()
	mut mod := llvm.new_llvm_module('main', builder)

	stmts := [binding.new_bound_return_with_expr_stmt(
		binding.new_bound_literal_expr(0)
	)]
	mod.declare_function(
		symbols.new_function_symbol(
			'main', []symbols.ParamSymbol{}, symbols.int_symbol),
		binding.new_bound_block_stmt(stmts)
	)
	mod.print_to_file('test.ll') ?
}