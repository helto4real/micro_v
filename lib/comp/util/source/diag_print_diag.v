module source

import strings
import term

pub fn write_diagnostic(mut sw SourceWriter, location &TextLocation, text string, nr_lines_to_show int) {
	source := location.source
	src := source.str()
	error_line_nr := source.line_nr(location.pos.pos)
	error_line := source.lines[error_line_nr - 1]
	error_col := location.pos.pos - error_line.start + 1

	mut line_nr_start := error_line_nr - nr_lines_to_show
	if line_nr_start < 1 {
		line_nr_start = 1
	}

	error_line_nr_end := source.line_nr(location.pos.pos + location.pos.len)
	mut line_nr_end := error_line_nr_end + nr_lines_to_show
	if line_nr_end > source.lines.len {
		line_nr_end = source.lines.len
	}

	mut err_end_pos := location.pos.pos + location.pos.len
	if err_end_pos > src.len {
		err_end_pos = src.len
	}

	sw.write('$location.source.filename:$error_line_nr:$error_col: ')
	sw.write(term.red('error: '))
	sw.writeln(text)

	mut b := strings.new_builder(0)
	nr_of_digits := line_nr_end.str().len
	for i in line_nr_start .. line_nr_end + 1 {
		line := source.lines[i - 1]
		nr_of_zeros_to_add := nr_of_digits - i.str().len
		if nr_of_zeros_to_add > 0 {
			b.write_string(' 0'.repeat(nr_of_zeros_to_add))
		} else {
			b.write_string(' ')
		}
		b.write_string('$i')
		b.write_string(' | ')
		if i == error_line_nr {
			prefix := src[line.start..location.pos.pos].replace('\t', '  ')
			error := src[location.pos.pos..err_end_pos].replace('\t', '  ')
			postfix := src[location.pos.pos + location.pos.len..line.start + line.len].replace('\t',
				'  ')

			b.write_string(prefix)
			b.write_string(term.red(error))
			b.writeln(postfix)
			b.write_string(' '.repeat(nr_of_digits + 1))
			b.write_string(' | ')
			b.writeln(term.red('${' '.repeat(prefix.len)}${'~'.repeat(location.pos.len)}'))
		} else {
			b.writeln(src[line.start..line.start + line.len].replace('\t', '  '))
		}
	}
	sw.writeln(b.str())
	sw.writeln('')
}
