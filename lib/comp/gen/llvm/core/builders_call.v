module core

import lib.comp.binding
import lib.comp.symbols

pub struct CallBuilder {
	name string
	fn_ref      &C.LLVMValueRef
	is_built_in bool
	func Function
pub mut:
	ctx    &Context
	params []&C.LLVMValueRef
}

fn new_builtin_call(name string, ctx &Context) CallBuilder {
	return CallBuilder{
		name: name
		ctx: ctx
		fn_ref: ctx.mod.built_in_funcs[name]
		is_built_in: true
	}
}

fn emit_call(call_expr binding.BoundCallExpr, mut ctx &Context) &C.LLVMValueRef {
	func := ctx.mod.funcs[call_expr.func.id] or {
			panic('unexpected, $call_expr.func.name ($call_expr.func.id) func not declared')
	}
	mut params := []&C.LLVMValueRef{cap: call_expr.params.len}
	for param in call_expr.params {
		params << ctx.emit_expr(param)
	}

	mut call_builder := CallBuilder{
		name: func.func.name
		ctx: ctx
		func: func
		params: params
		fn_ref: func.llvm_func
		is_built_in: false
	}

	if call_expr.typ.kind == symbols.TypeSymbolKind.void_symbol {
		// no return value
		call_builder.emit()
		return 0
	}

	return call_builder.emit()
}

pub fn (mut cb CallBuilder) add_param(val_ref &C.LLVMValueRef) {
	cb.params << val_ref
}

pub fn (mut cb CallBuilder) add_lit_param(val symbols.LitVal) {
	lit_expr := binding.new_bound_literal_expr(val) as binding.BoundLiteralExpr
	cb.params << cb.ctx.emit_bound_litera_expr(lit_expr)
}

pub fn (mut cb CallBuilder) emit() &C.LLVMValueRef {
	if cb.is_built_in {
		return C.LLVMBuildCall(cb.ctx.mod.builder.builder_ref, cb.fn_ref, cb.params.data,
			cb.params.len, no_name.str)
	} else {
		fn_ref := cb.func.llvm_func
		fn_typ_ref := cb.func.llvm_func_typ
		return C.LLVMBuildCall2(cb.ctx.mod.builder.builder_ref, fn_typ_ref, fn_ref, cb.params.data, cb.params.len,
				no_name.str)
		
	}
}