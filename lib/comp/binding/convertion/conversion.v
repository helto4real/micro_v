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
	if from == to {
		return convertion.conv_ident
	}

	if from != symbols.void_symbol && to == symbols.any_symbol {
		return convertion.conv_implicit
	}
	if from == symbols.any_symbol && to != symbols.void_symbol {
		return convertion.conv_explicit
	}

	if from == symbols.bool_symbol || from == symbols.int_symbol {
		if to == symbols.string_symbol {
			return convertion.conv_explicit
		}
	}
	if from == symbols.string_symbol {
		if to == symbols.bool_symbol || to == symbols.int_symbol {
			return convertion.conv_explicit
		}
	}
	return convertion.conv_none
}
