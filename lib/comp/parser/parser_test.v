module parser
import lib.comp.token

fn test_current() {
	// some hard combinations to parse with or whithout whitespace
	mut p := new_parser_from_text('')
	tok := p.current_token()
	assert tok.kind == token.Kind.eof
}

fn test_current_peek() {
	// some hard combinations to parse with or whithout whitespace
	mut p := new_parser_from_text('abc 123')
	
	assert p.current_token().kind == .name
	assert p.peek_token(1).kind == .number
	assert p.peek_token(2).kind == .eof
	assert p.peek_token(3).kind == .eof
	assert p.peek_token(200).kind == .eof
}

fn test_next_token() {
	mut p := new_parser_from_text('abc 123')
	assert p.current_token().kind == .name
	// Todo: why I cannot just do p.next_token().kind == .name??
	t := p.next_token()
	assert t.kind == .name
	assert p.current_token().kind == .number
}

fn test_match_token() {
	mut p := new_parser_from_text('abc 123')
	mut tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.pos.len == 3
	assert tok.pos.col == 1
	assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	assert tok.pos.col == 5
	assert tok.pos.ln == 1
	assert tok.lit == '123'
}

fn test_match_line_token() {
	mut p := new_parser_from_text('abc 123\ncba 321\r\nabc 123')
	mut tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.pos.len == 3
	assert tok.pos.col == 1
	assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	assert tok.pos.col == 5
	assert tok.pos.ln == 1
	assert tok.lit == '123'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 8
	assert tok.pos.len == 3
	assert tok.pos.col == 1
	assert tok.pos.ln == 2
	assert tok.lit == 'cba'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 12
	assert tok.pos.len == 3
	assert tok.pos.col == 5
	assert tok.pos.ln == 2
	assert tok.lit == '321'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 17
	assert tok.pos.len == 3
	assert tok.pos.col == 1
	assert tok.pos.ln == 3
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 21
	assert tok.pos.len == 3
	assert tok.pos.col == 5
	assert tok.pos.ln == 3
	assert tok.lit == '123'
}

fn test_match_token_not_exixt() {
	mut p := new_parser_from_text('123')
	tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.lit == ''

}
