module convertion

import lib.comp.symbols

pub const (
	conv_none     = new_convertion(false, false, false)
	conv_ident    = new_convertion(true, true, true)
	conv_implicit = new_convertion(true, false, true)
	conv_explicit = new_convertion(true, false, false)
)

struct Convertion {
pub:
	exists      bool
	is_identity bool
	is_explicit bool
	is_implicit bool
}

fn new_convertion(exists bool, is_identity bool, is_implicit bool) Convertion {
	return Convertion{
		exists: exists
		is_identity: is_identity
		is_implicit: is_implicit
		is_explicit: exists && !is_implicit
	}
}

pub fn classify(from symbols.TypeSymbol, to symbols.TypeSymbol) Convertion {
	if from.kind != .void_symbol && to.kind == .any_symbol {
		return convertion.conv_implicit
	}
	if from.kind == .any_symbol && to.kind != .void_symbol {
		return convertion.conv_explicit
	}

	if from is symbols.StructTypeSymbol {
		if to is symbols.StructTypeSymbol {
			if from == to {
				return convertion.conv_ident
			}
		} else {
			if to.kind == .string_symbol && to.name == 'string' {
				return convertion.conv_implicit
			}
		}
	} else {
		if from.kind == to.kind {
			return convertion.conv_ident
		}
		if from.kind == .bool_symbol || from.kind == .int_symbol || from.kind == .i64_symbol{
			if to.kind == .string_symbol {
				return convertion.conv_explicit
			}
		}
		if from.kind == .string_symbol {
			if to.kind == .bool_symbol || to.kind == .int_symbol {
				return convertion.conv_explicit
			}
			if to.name == 'String' {
				return convertion.conv_implicit
			}
		}
		if from.kind == .byte_symbol {
			if to.kind == .char_symbol {
				return convertion.conv_explicit
			}
		}
		if from.kind == .char_symbol {
			if to.kind == .byte_symbol {
				return convertion.conv_explicit
			}
		}
		if from.kind == .int_symbol {
			if to.kind == .i64_symbol {
				return convertion.conv_implicit
			}
			if to is symbols.StructTypeSymbol {
				if to.is_ref {
					return convertion.conv_explicit
				}
			}
		}
	}

	return convertion.conv_none
}
