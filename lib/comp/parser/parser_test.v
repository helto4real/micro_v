module parser

import lib.comp.token
import lib.comp.ast
import lib.comp.ast.walker

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
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 1
	assert tok.lit == '123'
}

fn test_match_line_token() {
	mut p := new_parser_from_text('abc 123\ncba 321\r\nabc 123')
	mut tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 1
	assert tok.lit == '123'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 8
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 2
	assert tok.lit == 'cba'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 12
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 2
	assert tok.lit == '321'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 17
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 3
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 21
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 3
	assert tok.lit == '123'
}

fn test_match_token_not_exixt() {
	mut p := new_parser_from_text('123')
	tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.lit == ''
}

fn test_separated_syntax_list() {
	mut p := new_parser_from_text('a, b, c')
	sep_node_list := p.parse_args()

	assert p.log.all.len == 0

	assert sep_node_list.len() == 3
	assert ((sep_node_list.at(0) as ast.Expr) as ast.NameExpr).ident.lit == 'a'
	assert ((sep_node_list.at(1) as ast.Expr) as ast.NameExpr).ident.lit == 'b'
	assert ((sep_node_list.at(2) as ast.Expr) as ast.NameExpr).ident.lit == 'c'

	mut sep_tok1 := sep_node_list.sep_at(0) as token.Token
	assert sep_tok1.kind == .comma
	assert sep_tok1.lit == ','
	mut sep_tok2 := sep_node_list.sep_at(1) as token.Token
	assert sep_tok2.kind == .comma
	assert sep_tok2.lit == ','
}

fn test_call_parser() {
	mut p := new_parser_from_text("print('hello world')")
	call_expr := p.parse_call_expr()

	assert p.log.all.len == 0

	assert call_expr is ast.CallExpr
}
