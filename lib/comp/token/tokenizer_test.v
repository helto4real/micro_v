module token

// EOF specific tests
fn test_last_is_eof() {
	mut tkz := new_tokenizer_from_string('')
	tok := tkz.next_token()
	assert tok.kind == .eof
}

// name token tests

fn test_name() {
	mut tkz := new_tokenizer_from_string('hello')
	tok := tkz.next_token()
	assert tok.kind == .name
	assert tok.lit == 'hello'
	assert tok.pos.pos == 0
}

fn test_two_names() {
	mut tkz := new_tokenizer_from_string('hello world')
	mut tok := tkz.next_token()
	assert tok.kind == .name
	assert tok.lit == 'hello'
	assert tok.pos.pos == 0

	tok = tkz.next_token()
	assert tok.kind == .name
	assert tok.lit == 'world'
	assert tok.pos.pos == 6
}

// EOF specific tests
fn test_last_is_eof_scan_all() {
	mut tkz := new_tokenizer_from_string('')
	tokens := tkz.scan_all()
	assert tokens[0].kind == .eof
}

fn test_name_scan_all() {
	mut tkz := new_tokenizer_from_string('hello')
	tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0
}

fn test_two_names_scan_all() {
	mut tkz := new_tokenizer_from_string('hello world')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0

	assert tokens[1].lit == 'world'
	assert tokens[1].kind == .name
	assert tokens[1].pos.pos == 6
}

// number token tests

fn test_number() {
	mut tkz := new_tokenizer_from_string('12345')
	tok := tkz.next_token()
	assert tok.kind == .number
	assert tok.lit == '12345'
	assert tok.pos.pos == 0
}

// name and number compo tests
fn test_name_and_number() {
	mut tkz := new_tokenizer_from_string('hello 12345')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0
	assert tokens[0].pos.len == 5

	assert tokens[1].kind == .number
	assert tokens[1].lit == '12345'
	assert tokens[1].pos.pos == 6
	assert tokens[1].pos.len == 5
}

// name and number compo tests
fn test_name_and_number_correct_lnr_ln() {
	mut tkz := new_tokenizer_from_string('hello\n12345')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0
	assert tokens[0].pos.len == 5

	assert tokens[1].kind == .number
	assert tokens[1].lit == '12345'
	assert tokens[1].pos.pos == 6
	assert tokens[1].pos.len == 5
}

fn test_name_and_number_correct_lnr_cr_ln() {
	mut tkz := new_tokenizer_from_string('hello\r\n12345')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0
	assert tokens[0].pos.len == 5

	assert tokens[1].kind == .number
	assert tokens[1].lit == '12345'
	assert tokens[1].pos.pos == 7
	assert tokens[1].pos.len == 5
}

// test that multi line returns correct col and line number
fn test_name_and_number_correct_multiple_lines() {
	mut tkz := new_tokenizer_from_string('hello\n12345\nworld\n1212')

	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].pos.pos == 0
	assert tokens[0].pos.len == 5

	assert tokens[1].pos.pos == 6
	assert tokens[1].pos.len == 5

	assert tokens[2].pos.pos == 12
	assert tokens[2].pos.len == 5

	assert tokens[3].pos.pos == 18
	assert tokens[3].pos.len == 4
}

// name and number compo tests
fn test_number_and_name() {
	mut tkz := new_tokenizer_from_string('12345 hello')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .number
	assert tokens[0].lit == '12345'
	assert tokens[0].pos.pos == 0

	assert tokens[1].kind == .name
	assert tokens[1].lit == 'hello'
	assert tokens[1].pos.pos == 6
}

fn test_name_and_number_and_namewithnumber() {
	mut tkz := new_tokenizer_from_string('hello 12345 namewith1234')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .name
	assert tokens[0].lit == 'hello'
	assert tokens[0].pos.pos == 0

	assert tokens[1].kind == .number
	assert tokens[1].lit == '12345'
	assert tokens[1].pos.pos == 6

	assert tokens[2].kind == .name
	assert tokens[2].lit == 'namewith1234'
	assert tokens[2].pos.pos == 12
}

// Test the string literal
fn test_string_literal_double_quote() {
	mut tkz := new_tokenizer_from_string('"hello world"')
	mut tok := tkz.next_token()
	assert tok.kind == .string
	assert tok.lit == 'hello world'
}

fn test_string_literal_single_quote() {
	mut tkz := new_tokenizer_from_string("'hello world'")
	mut tok := tkz.next_token()
	assert tok.kind == .string
	assert tok.lit == 'hello world'
}

fn test_string_literal_error_missing_end_quote() {
	mut tkz := new_tokenizer_from_string("'hello world")
	mut tok := tkz.next_token()
	assert tok.kind == .string
	assert tok.lit == ''
	assert tkz.log.all.len == 1
	assert tkz.log.all[0].pos.pos == 0
}

fn test_para() {
	mut tkz := new_tokenizer_from_string('(){}')
	mut tok := tkz.next_token()
	assert tok.kind == .lpar
	assert tok.lit == '('
	tok = tkz.next_token()
	assert tok.kind == .rpar
	assert tok.lit == ')'
	tok = tkz.next_token()
	assert tok.kind == .lcbr
	assert tok.lit == '{'
	tok = tkz.next_token()
	assert tok.kind == .rcbr
	assert tok.lit == '}'
}

fn test_single_operators() {
	mut tkz := new_tokenizer_from_string('+ - * /')
	mut tok := tkz.next_token()
	assert tok.kind == .plus
	assert tok.lit == '+'
	tok = tkz.next_token()
	assert tok.kind == .minus
	assert tok.lit == '-'
	tok = tkz.next_token()
	assert tok.kind == .mul
	assert tok.lit == '*'
	tok = tkz.next_token()
	assert tok.kind == .div
	assert tok.lit == '/'
}

fn test_dot_comma_colon_semicolon() {
	mut tkz := new_tokenizer_from_string('. , : ;')
	mut tok := tkz.next_token()
	assert tok.kind == .dot
	assert tok.lit == '.'
	tok = tkz.next_token()
	assert tok.kind == .comma
	assert tok.lit == ','
	tok = tkz.next_token()
	assert tok.kind == .colon
	assert tok.lit == ':'
	tok = tkz.next_token()
	assert tok.kind == .semcol
	assert tok.lit == ';'
	tok = tkz.next_token()
}

fn test_dot_comma_colon_semicolon_2() {
	mut tkz := new_tokenizer_from_string('.,:;')
	mut tok := tkz.next_token()
	assert tok.kind == .dot
	assert tok.lit == '.'
	tok = tkz.next_token()
	assert tok.kind == .comma
	assert tok.lit == ','
	tok = tkz.next_token()
	assert tok.kind == .colon
	assert tok.lit == ':'
	tok = tkz.next_token()
	assert tok.kind == .semcol
	assert tok.lit == ';'
	tok = tkz.next_token()
}

fn test_assign_declassign() {
	// some hard combinations to parse with or whithout whitespace
	mut tkz := new_tokenizer_from_string('= := =:= : :=::=')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .eq
	assert tokens[0].lit == '='
	assert tokens[1].kind == .colon_eq
	assert tokens[1].lit == ':='
	assert tokens[2].kind == .eq
	assert tokens[2].lit == '='
	assert tokens[3].kind == .colon_eq
	assert tokens[3].lit == ':='
	assert tokens[4].kind == .colon
	assert tokens[4].lit == ':'
	assert tokens[5].kind == .colon_eq
	assert tokens[5].lit == ':='
	assert tokens[6].kind == .colon
	assert tokens[6].lit == ':'
	assert tokens[7].kind == .colon_eq
	assert tokens[7].lit == ':='
}

fn test_eq_ne() {
	// some hard combinations to parse with or whithout whitespace
	mut tkz := new_tokenizer_from_string('== = != =!= !!=')
	mut tokens := tkz.scan_all()
	assert tokens[0].kind == .eq_eq
	assert tokens[0].lit == '=='
	assert tokens[1].kind == .eq
	assert tokens[1].lit == '='
	assert tokens[2].kind == .exl_mark_eq
	assert tokens[2].lit == '!='
	assert tokens[3].kind == .eq
	assert tokens[3].lit == '='
	assert tokens[4].kind == .exl_mark_eq
	assert tokens[4].lit == '!='
	assert tokens[5].kind == .exl_mark
	assert tokens[5].lit == '!'
	assert tokens[6].kind == .exl_mark_eq
	assert tokens[6].lit == '!='
}
