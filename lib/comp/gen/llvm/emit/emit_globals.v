module emit

import lib.comp.gen.llvm.core

const (
	no_name = '\00'
)

pub enum GlobalVarRefType {
	jmp_buff
	printf_str
	printf_str_nl
	printf_num
	sprintf_buff
	str_true
	str_false
	nl
}

pub fn (mut em EmitModule) emit_global_vars() {
	// add the global sprintf buffer
	buff_typ := em.ctx.int8_type().to_array_type(21)
	buff_val := em.mod.add_global('sprintf_buff', buff_typ)

	null_val := buff_typ.const_null()
	buff_val.set_initializer(null_val)
	em.global_const[GlobalVarRefType.sprintf_buff] = buff_val

	jmp_buf_typ_ref := em.types['C.JumpBuffer'] or {
		panic('type `C.JumpBuffer` is not in $em.types.keys()  $')
	}
	mut values := [core.const_int(em.ctx.int64_type(), u64(0), false)]
	init_struct := jmp_buf_typ_ref.create_const_named_struct(values)
	global_jmp_buff_val := em.mod.add_global('jmp_buf', jmp_buf_typ_ref)
	global_jmp_buff_val.set_initializer(init_struct)
	em.global_const[GlobalVarRefType.jmp_buff] = global_jmp_buff_val
}

fn (mut em EmitModule) get_global_string(glob_typ GlobalVarRefType) core.Value {
	match glob_typ {
		.printf_str {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('%s', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		.printf_str_nl {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('%s\n', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		.printf_num {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('%d', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		.str_true {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('true', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		.str_false {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('false', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		.nl {
			return em.global_const[glob_typ] or {
				str_ref := em.bld.create_global_string_ptr('\n', '')
				em.global_const[glob_typ] = str_ref
				str_ref
			}
		}
		else {}
	}
	panic('unexepected, missing handle of global string')
}
