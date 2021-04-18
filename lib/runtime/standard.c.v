module runtime

fn C.printf(fmt &byte, params ...&byte) int

fn C.exit(code int)

fn C.sprintf(buffer &byte, fmt &byte, params ...&byte) int

fn C.strlen(str &char) int

struct C.JumpBuffer {
	var i64
}
fn C.longjmp(b &C.JumpBuffer, val i64) 
fn C.setjmp(b &C.JumpBuffer) i64
// declare void @longjmp(%JumpBuffer*, i64)

// declare i64 @setjmp(%JumpBuffer*)