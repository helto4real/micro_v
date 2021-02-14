module binding

import lib.comp.util

pub fn (mut p Binder) error(text string, pos util.Pos) {
	p.errors << util.Message{
		text: text
		pos: pos
	}
}
