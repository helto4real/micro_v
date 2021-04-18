module emit

import lib.comp.symbols
import lib.comp.gen.llvm.core


[inline]
fn (em &EmitModule) get_ref_type_from_type_symb(symb_typ symbols.TypeSymbol) core.Type {
	mut typ := em.get_type_from_type_symb(symb_typ)
	if symb_typ.is_ref {
		typ = typ.to_pointer_type(0)
	}
	return typ
}
fn (em &EmitModule) get_type_from_type_symb(typ symbols.TypeSymbol) core.Type {
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.kind {
				.int_symbol {
					return em.ctx.int32_type()
				}
				.i64_symbol {
					return em.ctx.int64_type()
				}
				.bool_symbol {
					return em.ctx.int1_type()
				}
				.string_symbol {
					return em.ctx.int8_type().to_pointer_type(0)
				}
				.byte_symbol {
					return em.ctx.int8_type()
				}
				.char_symbol {
					return em.ctx.int8_type()
				}
				else {
					panic('unexpected, unsupported built-in type: $typ')
				}
			}
		}
		symbols.ArrayTypeSymbol {
			elem_typ := em.get_type_from_type_symb(typ.elem_typ)
			return elem_typ.to_array_type(typ.len) 
		}
		symbols.VoidTypeSymbol {
			return  em.ctx.void_type()
		}
		symbols.StructTypeSymbol {
			return em.types[typ.name] or { panic('unexpected, type $typ.name not found in symols table ${em.types.keys()}') }
		}
		else {
			panic('unexpected, unsupported type ref $typ, $typ.kind')
		}
	}

	panic('unexpected, unsupported type: $typ')
}
