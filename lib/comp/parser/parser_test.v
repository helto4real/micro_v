module parser

import lib.comp.token
import lib.comp.ast

fn test_current() {
	// some hard combinations to parse with or whithout whitespace
	mut p := new_parser_from_text('')
	tok := p.current_token()
	assert tok.kind == token.Kind.eof
}

fn test_current_peek() {
	// some hard combinations to parse with or whithout whitespace
	mut p := new_parser_from_text('abc 123')

	assert p.current_token().kind == .name
	assert p.peek_token(1).kind == .number
	assert p.peek_token(2).kind == .eof
	assert p.peek_token(3).kind == .eof
	assert p.peek_token(200).kind == .eof
}

fn test_next_token() {
	mut p := new_parser_from_text('abc 123')
	assert p.current_token().kind == .name
	// Todo: why I cannot just do p.next_token().kind == .name??
	t := p.next_token()
	assert t.kind == .name
	assert p.current_token().kind == .number
}

fn test_match_token() {
	mut p := new_parser_from_text('abc 123')
	mut tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 1
	assert tok.lit == '123'
}

fn test_match_line_token() {
	mut p := new_parser_from_text('abc 123\ncba 321\r\nabc 123')
	mut tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 1
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 4
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 1
	assert tok.lit == '123'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 8
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 2
	assert tok.lit == 'cba'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 12
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 2
	assert tok.lit == '321'

	tok = p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 17
	assert tok.pos.len == 3
	// assert tok.pos.col == 1
	// assert tok.pos.ln == 3
	assert tok.lit == 'abc'

	tok = p.match_token(.number)
	assert tok.kind == .number
	assert tok.pos.pos == 21
	assert tok.pos.len == 3
	// assert tok.pos.col == 5
	// assert tok.pos.ln == 3
	assert tok.lit == '123'
}

fn test_match_token_not_exixt() {
	mut p := new_parser_from_text('123')
	tok := p.match_token(.name)
	assert tok.kind == .name
	assert tok.pos.pos == 0
	assert tok.lit == ''
}

fn test_separated_syntax_list() {
	mut p := new_parser_from_text('a, b, c')
	sep_node_list := p.parse_args()

	assert p.log.all.len == 0

	assert sep_node_list.len() == 3
	assert ((sep_node_list.at(0) as ast.Expr) as ast.NameExpr).name_tok.lit == 'a'
	assert ((sep_node_list.at(1) as ast.Expr) as ast.NameExpr).name_tok.lit == 'b'
	assert ((sep_node_list.at(2) as ast.Expr) as ast.NameExpr).name_tok.lit == 'c'

	mut sep_tok1 := sep_node_list.sep_at(0) as token.Token
	assert sep_tok1.kind == .comma
	assert sep_tok1.lit == ','
	mut sep_tok2 := sep_node_list.sep_at(1) as token.Token
	assert sep_tok2.kind == .comma
	assert sep_tok2.lit == ','
}

fn test_call_parser() {
	mut p := new_parser_from_text("print('hello world')")
	call_expr := p.parse_call_expr()

	assert p.log.all.len == 0

	assert call_expr is ast.CallExpr
}

fn test_type_node_parser() {
	mut p := new_parser_from_text('test')
	non_ref_typ := p.parse_type_node(false)
	assert p.log.all.len == 0

	assert non_ref_typ.is_ref == false
	assert non_ref_typ.name_tok.lit == 'test'

	p = new_parser_from_text('&test')
	ref_typ := p.parse_type_node(false)
	assert p.log.all.len == 0

	assert ref_typ.is_ref == true
	assert ref_typ.name_tok.lit == 'test'
}

fn test_keywords_parser() {
	mut p := new_parser_from_text('break')
	mut keyword := p.parse_stmt()
	assert keyword is ast.BreakStmt

	p = new_parser_from_text('continue')
	keyword = p.parse_stmt()
	assert keyword is ast.ContinueStmt

	p = new_parser_from_text('return')
	keyword = p.parse_stmt()
	assert keyword is ast.ReturnStmt

	p = new_parser_from_text('module main')
	keyword = p.parse_stmt()
	assert keyword is ast.ModuleStmt
}

fn test_param_node_parser() {
	// parse parameter that are immutable
	mut p := new_parser_from_text('name_tok type')
	imut_param := p.parse_param_node()
	assert p.log.all.len == 0

	assert imut_param.name_tok.lit == 'name_tok'
	assert imut_param.is_mut == false
	assert imut_param.typ.name_tok.lit == 'type'

	// parse parameter that are mutable
	p = new_parser_from_text('mut name_tok type')
	mut_param := p.parse_param_node()
	assert p.log.all.len == 0

	assert mut_param.name_tok.lit == 'name_tok'
	assert mut_param.is_mut == true
	assert mut_param.typ.name_tok.lit == 'type'
	assert mut_param.typ.is_ref == true

	// parse parameter with reference type
	p = new_parser_from_text('name_tok &type')
	ref_param := p.parse_param_node()
	assert p.log.all.len == 0

	assert ref_param.name_tok.lit == 'name_tok'
	assert ref_param.is_mut == false
	assert ref_param.typ.name_tok.lit == 'type'
	assert ref_param.typ.is_ref == true
}

fn test_array_parser() {
	mut p := new_parser_from_text('x[1]')
	mut expr := p.parse_expr()
	assert p.log.all.len == 0
	assert expr.kind == .index_expr

	p = new_parser_from_text('[1, 2, 3 ,4]!')
	expr = p.parse_array_expr()
	assert p.log.all.len == 0
	// parse the C function
	p = new_parser_from_text('[1, 2, 3 ,4]')
	expr = p.parse_array_expr()
	assert p.log.all.len == 0
}
fn test_fn_node_parser() {
	mut p := new_parser_from_text('fn test() string {10}')
	mut expr := p.parse_function()
	assert p.log.all.len == 0
	assert expr.fn_key.kind == .key_fn
	assert expr.name_expr.name_tok.lit == 'test'
	assert expr.params.len() == 0
	assert expr.typ_node.name_tok.lit == 'string'
	assert expr.typ_node.is_void == false
	assert expr.receiver_node.is_empty == true

	p = new_parser_from_text('fn test() {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == true

	p = new_parser_from_text('fn (x string) test() {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == true
	assert expr.receiver_node.is_empty == false
	assert expr.receiver_node.name_tok.lit == 'x'
	assert expr.receiver_node.is_ref == false
	
	p = new_parser_from_text('fn (x &string) test() {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == true
	assert expr.receiver_node.is_empty == false
	assert expr.receiver_node.name_tok.lit == 'x'
	assert expr.receiver_node.is_ref == true

	p = new_parser_from_text('fn (mut x string) test() {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == true
	assert expr.receiver_node.is_empty == false
	assert expr.receiver_node.name_tok.lit == 'x'
	assert expr.receiver_node.is_ref == true
	assert expr.receiver_node.is_mut == true

	p = new_parser_from_text('fn test(param string) int {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == false
	assert expr.typ_node.name_tok.lit == 'int'
	assert expr.params.len() == 1
	mut param := expr.params.at(0) as ast.ParamNode
	assert param.name_tok.lit == 'param'
	assert param.typ.name_tok.lit == 'string'
	assert param.typ.is_ref == false

	p = new_parser_from_text('fn test(param &RefStruct) int {}')
	expr = p.parse_function()
	assert p.log.all.len == 0
	assert expr.typ_node.is_void == false
	assert expr.typ_node.name_tok.lit == 'int'
	assert expr.params.len() == 1
	param = expr.params.at(0) as ast.ParamNode
	assert param.name_tok.lit == 'param'
	assert param.typ.name_tok.lit == 'RefStruct'
	assert param.typ.is_ref == true

	p = new_parser_from_text('fn variadic(vari ...string) {}')
	expr = p.parse_function()
	assert p.log.all.len == 0

	p = new_parser_from_text('fn C.printf(vari charptr)')
	expr = p.parse_function()
	assert p.log.all.len == 0
}

/*
fn_key: fn_key
		name_tok:name_tok
		lpar_tok: lpar_tok
		params: params
		rpar_tok: rpar_tok
		typ_node:typ_node
		block: block
*/
