module repl

enum Movement {
	up
	down
	left
	right
	home
	end
	page_up
	page_down
}

struct View {
pub:
	raw    string
	cursor Cursor
}

struct Cursor {
pub mut:
	pos_x int
	pos_y int
}

fn (mut c Cursor) set(x int, y int) {
	c.pos_x = x
	c.pos_y = y
}

fn (mut c Cursor) move(x int, y int) {
	c.pos_x += x
	c.pos_y += y
}

fn (c Cursor) xy() (int, int) {
	return c.pos_x, c.pos_y
}
