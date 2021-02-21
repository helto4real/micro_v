module parser

[inline]
// peek_var_dec matches 'name = expr'
fn (mut p Parser) peek_var_decl(n int) bool {
	return p.peek_token(n).kind == .name && p.peek_token(n+1).kind==.colon_eq
}

[inline]
// peek_assignment matches 'name = expr'
fn (mut p Parser) peek_assignment(n int) bool {
	return p.peek_token(n).kind == .name && p.peek_token(n+1).kind == .eq
}
