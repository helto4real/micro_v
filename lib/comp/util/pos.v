module util

pub struct Pos {
pub:
	pos int // position in textfile
	ln  int // line number
	col int // column of line
	len int // length of the error token
}

pub fn new_pos(pos int, len int, ln int, col int) Pos {
	return Pos{
		pos: pos
		len: len
		ln: ln
		col: col
	}
}
