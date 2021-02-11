module token

fn test_last_is_eof() {
	mut tkz := new_tokenizer_from_string('')
	tok := tkz.next_token()
	assert tok.kind == .eof 
}

fn test_name() {
	mut tkz := new_tokenizer_from_string('hello')
	tok := tkz.next_token()
	assert tok.kind == .name 
	assert tok.lit == 'hello' 
	assert tok.pos.pos == 0
	
}