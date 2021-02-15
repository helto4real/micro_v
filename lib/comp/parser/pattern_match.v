module parser

[inline]
// peek_assignment matches 'name := expr' or 'name = expr'
fn (mut p Parser) peek_assignment(n int) bool {
	return p.peek_token(n).kind == .name && (p.peek_token(n+1).kind == .eq || p.peek_token(n+1).kind==.colon_eq)
}
