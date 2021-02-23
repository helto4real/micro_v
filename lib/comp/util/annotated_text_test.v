module util

fn test_basic_annotation() {
	text := '
			a:=1
			{
				b:=1
			}
			'
	expected := 'a:=1
{
	b:=1
}
'
	assert expected == unindent(text)
}
