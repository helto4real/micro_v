module token

import util

pub fn (mut t Tokenizer) error(text string) {
	t.errors << util.Message {
		text: text 
		pos: util.Pos {
			pos: t.pos
			ln: t.ln
			col: t.col
		}
	}
}