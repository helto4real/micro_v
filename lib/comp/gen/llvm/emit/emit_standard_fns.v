module emit
import lib.comp.gen.llvm.core

pub fn (mut em EmitModule) emit_standard_funcs() {
	em.emit_longjmp_setjmp()
}

fn (mut em EmitModule) emit_longjmp_setjmp() {
	jmp_buf_typ_ref := em.types['JumpBuffer']

	mut values := [core.const_int(em.ctx.int64_type(), u64(0), false)]

	init_struct := jmp_buf_typ_ref.create_const_named_struct(values)

	global_jmp_buff_val := em.mod.add_global('jmp_buf', jmp_buf_typ_ref)
	global_jmp_buff_val.set_initializer(init_struct)
	em.global_const[GlobalVarRefType.jmp_buff] = global_jmp_buff_val


	// jongjmp declaration
	mut long_jmp_decl := new_fn_decl('longjmp', em.ctx.void_type(), mut em)
	long_jmp_decl.params << jmp_buf_typ_ref.to_pointer_type(0)
	long_jmp_decl.params << em.ctx.int64_type()
	em.built_in_funcs['longjmp'] = long_jmp_decl.emit()

	// setjmp declaration
	mut set_jmp_decl := new_fn_decl('setjmp', em.ctx.int64_type(), mut em)
	set_jmp_decl.params << jmp_buf_typ_ref.to_pointer_type(0)
	em.built_in_funcs['setjmp'] = set_jmp_decl.emit()

}


