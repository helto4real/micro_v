module runtime

fn C.printf(fmt &byte, params ...&byte) int

fn C.exit(code int)

fn C.sprintf(buffer &byte, fmt &byte, params ...&byte) int

fn C.strlen(str &char) int