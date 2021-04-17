module emit
import lib.comp.symbols
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

pub fn (mut em EmitModule) emit_global_types() {

	standard_structs := em.get_standard_struct_types()
	for standard_struct in standard_structs {
		typ := em.ctx.new_named_struct_type(standard_struct.name)
		em.types[standard_struct.name] = typ
		mut member_types := []core.Type{}
		for member in standard_struct.members {
			member_type := em.get_type_from_type_symb(member.typ)
			if member.typ.is_ref {
				member_types << member_type.to_pointer_type(0)
			} else {
				member_types << member_type
			}
		}
		typ.struct_set_body(member_types, false)
	}
}

pub fn (mut em EmitModule) get_standard_struct_types() []symbols.StructTypeSymbol {
	mut res := []symbols.StructTypeSymbol{}
	
	// declare the jumb_buf
	// Todo: size depending on target arch
	mut jmp_buf_symbol := symbols.new_struct_symbol('lib.runtime', 'JumpBuffer', false, false)
	jmp_buf_symbol.members << symbols.new_struct_type_member('', symbols.i64_symbol)
	res << jmp_buf_symbol

	return res
}

pub fn (mut em EmitModule) emit_global_vars() {
	// add the global sprintf buffer
	buff_typ := em.ctx.int8_type().to_array_type(21)
	buff_val := em.mod.add_global('sprintf_buff', buff_typ)

	null_val := buff_typ.const_null()
	buff_val.set_initializer(null_val)
	em.global_const[GlobalVarRefType.sprintf_buff] = buff_val
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