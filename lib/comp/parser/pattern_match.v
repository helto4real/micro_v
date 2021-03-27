module parser

import lib.comp.token

// peek_var_dec matches 'name = expr'
fn (mut p Parser) peek_var_decl(n int) bool {
	mut i := n
	mut expected_kind := token.Kind.name
	// we expect a valid name expr to be name and dots
	for {
		if p.peek_token(i).kind != expected_kind {
			return false
		}
		if p.peek_token(i + 1).kind == .colon_eq {
			return true
		}
		i += 1
		expected_kind = if expected_kind == .name { token.Kind.dot } else { token.Kind.name }
	}
	return false
}

// peek_assignment matches 'name = expr'
fn (mut p Parser) peek_assignment(n int) bool {
	mut i := n
	mut expected_kind := token.Kind.name
	// we expect a valid name expr to be name and dots
	for {
		if p.peek_token(i).kind != expected_kind {
			return false
		}
		if p.peek_token(i + 1).kind == .eq {
			return true
		}
		i += 1
		expected_kind = if expected_kind == .name { token.Kind.dot } else { token.Kind.name }
	}
	return false
}

// peek_assignment matches 'fn ident(..){}'
fn (mut p Parser) peek_fn_decl(n int) bool {
	return p.peek_token(n).kind == .key_fn
		|| (p.peek_token(n).kind == .key_mut && p.peek_token(n + 1).kind == .key_fn)
}

// peek_assignment matches 'struct x { element type ...}'
fn (mut p Parser) peek_struct_decl(n int) bool {
	return p.peek_token(n).kind == .key_struct && p.peek_token(n + 1).kind == .name
}

// peek_assignment matches ' Type{ member: type ...}'
fn (mut p Parser) peek_struct_init(n int) bool {
	return p.peek_token(n).kind == .name && p.peek_token(n + 1).kind == .lcbr
}
