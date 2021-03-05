module parser

// peek_var_dec matches 'name = expr'
fn (mut p Parser) peek_var_decl(n int) bool {
	return p.peek_token(n).kind == .name && p.peek_token(n + 1).kind == .colon_eq
}

// peek_assignment matches 'name = expr'
fn (mut p Parser) peek_assignment(n int) bool {
	return p.peek_token(n).kind == .name && p.peek_token(n + 1).kind == .eq
}
// peek_assignment matches 'name = expr'
fn (mut p Parser) peek_fn_decl(n int) bool {
	return p.peek_token(n).kind == .key_fn || 	(p.peek_token(n).kind == .key_mut && p.peek_token(n+1).kind == .key_fn) 
}
