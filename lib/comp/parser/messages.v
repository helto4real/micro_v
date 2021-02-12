module parser

import lib.comp.util

pub fn (mut p Parser) error(text string) {
	tok := p.current_token()
	p.errors << util.Message {
		text: text 
		pos: util.Pos {
			pos: tok.pos.pos
			ln: tok.pos.ln
			col: tok.pos.col
		}
	}
}