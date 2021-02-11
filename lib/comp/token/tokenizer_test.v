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
	mut tok := tkz.next_token()
	assert tok.kind == .name 
	assert tok.lit == 'hello' 
	assert tok.pos.pos == 0

	tok = tkz.next_token()
	assert tok.kind == .number 
	assert tok.lit == '12345' 
	assert tok.pos.pos == 6
}

// name and number compo tests
fn test_number_and_name() {
	mut tkz := new_tokenizer_from_string('12345 hello')
	mut tok := tkz.next_token()
	assert tok.kind == .number 
	assert tok.lit == '12345' 	
	assert tok.pos.pos == 0

	tok = tkz.next_token()
	assert tok.kind == .name 
	assert tok.lit == 'hello' 
	assert tok.pos.pos == 6
}


fn test_name_and_number_and_namewithnumber() {
	mut tkz := new_tokenizer_from_string('hello 12345 namewith1234')
	mut tok := tkz.next_token()
	assert tok.kind == .name 
	assert tok.lit == 'hello' 
	assert tok.pos.pos == 0

	tok = tkz.next_token()
	assert tok.kind == .number 
	assert tok.lit == '12345' 
	assert tok.pos.pos == 6

	tok = tkz.next_token()
	assert tok.kind == .name 
	assert tok.lit == 'namewith1234' 
	assert tok.pos.pos == 12
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
	assert tok.lit == 'hello world' 
	assert tok.kind == .string