import lib.comp.token
import os

fn main() {
	for {
		print('> ')
		line := os.get_line()
		if line == '' {
			break
		}
		mut tnz := token.new_tokenizer_from_string(line)
		mut token := tnz.next_token()
		for {
			println(token)
			if token.kind == .eof {
				break
			}
			token = tnz.next_token()
		}
	}
}
