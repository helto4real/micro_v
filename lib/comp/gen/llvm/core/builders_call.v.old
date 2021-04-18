module core

import lib.comp.binding
import lib.comp.symbols

pub struct CallBuilder {
	name        string
	fn_ref      &C.LLVMValueRef = 0
	is_built_in bool
	func        &Function = 0
pub mut:
	ctx    &Emitter = 0
	params []&C.LLVMValueRef
}

fn new_builtin_call(name string, ctx &Emitter) CallBuilder {
	f_ref := ctx.mod.built_in_funcs[name] or { panic('the builtin function $name is not declared') }
	return CallBuilder{
		name: name
		ctx: ctx
		fn_ref: f_ref
		is_built_in: true
	}
}

pub fn (mut cb CallBuilder) add_param(val_ref &C.LLVMValueRef) {
	cb.params << val_ref
}

pub fn (mut cb CallBuilder) add_lit_param(val symbols.LitVal) {
	lit_expr := binding.new_bound_literal_expr(val) as binding.BoundLiteralExpr
	cb.params << cb.ctx.emit_literal_expr(lit_expr)
}

pub fn (mut cb CallBuilder) emit() &C.LLVMValueRef {
	if cb.is_built_in {
		return C.LLVMBuildCall(cb.ctx.mod.builder.builder_ref, cb.fn_ref, cb.params.data,
			cb.params.len, no_name.str)
	} else {
		fn_ref := cb.func.func_ref
		fn_typ_ref := cb.func.func_typ_ref
		return C.LLVMBuildCall2(cb.ctx.mod.builder.builder_ref, fn_typ_ref, fn_ref, cb.params.data,
			cb.params.len, no_name.str)
	}
}
