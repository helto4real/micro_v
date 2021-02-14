module util

pub struct Pos {
pub:
	pos int // position in textfile
	ln  int // line number
	col int // column of line
}

pub fn new_pos(pos int, ln int, col int) Pos {
	return Pos{
		pos: pos
		ln: ln
		col: col
	}
}
