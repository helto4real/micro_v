module source

pub struct Pos {
pub:
	pos int // position in textfile
	len int // length of the error token
}

pub fn new_pos(pos int, len int) Pos {
	return Pos{
		pos: pos
		len: len
	}
}

pub fn new_pos_from_pos_bounds(start Pos, end Pos) Pos {
	return Pos{
		pos: start.pos
		len: end.pos - start.pos + end.len
	}
}

pub fn new_pos_from_bounds(start int, end int) Pos {
	return Pos{
		pos: start
		len: end - start
	}
}
