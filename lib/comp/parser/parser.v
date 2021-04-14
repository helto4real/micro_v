module parser

import strconv
import lib.comp.ast
import lib.comp.token
import lib.comp.util.source as src

pub struct Parser {
	source &src.SourceText
mut:
	syntax_tree &ast.SyntaxTree
	pos         int
	tokens      []token.Token
	mod         string
pub mut:
	log &src.Diagnostics // errors when parsing
	// doing import and module check in the parser
	// cause it is per-file dependent
	mod_ok_to_define    bool = true
	import_ok_to_define bool = true
}

fn new_parser(mut syntax_tree ast.SyntaxTree) &Parser {
	source := syntax_tree.source
	log := syntax_tree.log
	mut tnz := token.new_tokenizer_from_source_with_diagnostics(source, log)
	tokens := tnz.scan_all()
	mut parser := &Parser{
		syntax_tree: syntax_tree
		source: source
		tokens: tokens
		log: log
	}
	return parser
}

// new_parser_from_text, instance a parser from a text input
fn new_parser_from_text(text string) &Parser {
	mut syntax_tree := ast.new_syntax_tree(text)
	log := syntax_tree.log
	mut tnz := token.new_tokenizer_from_source_with_diagnostics(syntax_tree.source, log)
	tokens := tnz.scan_all()
	mut parser := &Parser{
		syntax_tree: syntax_tree
		source: syntax_tree.source
		tokens: tokens
		log: log
	}
	return parser
}

pub fn parse_syntax_tree(text string) &ast.SyntaxTree {
	mut syntax_tree := ast.new_syntax_tree(text)
	mut parser := new_parser(mut syntax_tree)
	parser.parse_comp_node()
	return syntax_tree
}

pub fn parse_syntax_tree_from_file(filename string) ?&ast.SyntaxTree {
	mut syntax_tree := ast.new_syntax_tree_from_file(filename) ?
	mut parser := new_parser(mut syntax_tree)
	parser.parse_comp_node()
	return syntax_tree
}

pub fn (mut p Parser) parse_comp_node() {
	p.parse_members()
	_ := p.match_token(.eof)
}

pub fn (mut p Parser) parse_members() {
	for p.peek_token(0).kind != .eof {
		start_tok := p.current_token()
		member := p.parse_member()
		if member is ast.GlobStmt {
			if member.stmt.kind == .import_stmt {
				if !p.import_ok_to_define {
					p.log.error_import_can_only_be_defined_at_top_of_file(member.stmt.text_location())
				}
			} else if member.stmt.kind == .module_stmt {
				if p.mod.len > 0 {
					p.log.error_module_can_only_be_defined_once(member.stmt.text_location())
				}
				if !p.mod_ok_to_define {
					p.log.error_module_can_only_be_defined_as_first_statement(member.stmt.text_location())
				}
				p.mod_ok_to_define = false
			}
			if p.mod_ok_to_define && member.stmt.kind != .comment_stmt
				&& member.stmt.kind != .module_stmt {
				p.mod_ok_to_define = false
			}
			if p.import_ok_to_define && member.stmt.kind != .comment_stmt
				&& member.stmt.kind != .import_stmt && member.stmt.kind != .module_stmt {
				p.import_ok_to_define = false
			}
		}

		p.syntax_tree.root.members << member
		// if parse member did not consume any tokens
		// let's skip it and continue
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
	}
}

pub fn (mut p Parser) parse_member() ast.MemberNode {
	if p.peek_fn_decl(0) {
		return p.parse_function()
	} else if p.peek_struct_decl(0) {
		return p.parse_struct()
	} else {
		global_stmt := p.parse_global_stmt()
		return global_stmt
	}
}

pub fn (mut p Parser) parse_global_stmt() ast.MemberNode {
	stmt := p.parse_stmt()
	return ast.new_glob_stmt(p.syntax_tree, stmt)
}

pub fn (mut p Parser) parse_struct() ast.StructDeclNode {
	struct_key := p.match_token(.key_struct)
	expr := p.parse_name_expr()
	name_expr := expr as ast.NameExpr
	lcbr_tok := p.match_token(.lcbr)
	params := p.parse_struct_members()
	rcbr_tok := p.match_token(.rcbr)
	struct_ast := ast.new_struct_decl_node(p.syntax_tree, struct_key, name_expr, lcbr_tok,
		params, rcbr_tok)
	return struct_ast
}

fn (mut p Parser) parse_struct_members() []ast.StructMemberNode {
	mut members := []ast.StructMemberNode{}

	for p.current_token().kind != .eof && p.current_token().kind != .rcbr {
		start_tok := p.current_token()
		mut ref_tok := token.tok_void
		ident := p.match_token(.name)
		if p.current_token().kind == .amp {
			ref_tok = p.match_token(.amp)
		}
		expr := p.parse_name_expr()
		typ_expr := expr as ast.NameExpr
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
		members << ast.new_struct_member_node(p.syntax_tree, ident, ref_tok, typ_expr)
	}
	return members
}

pub fn (mut p Parser) parse_receiver() ast.ReceiverNode {
	if p.current_token().kind != .lpar {
		return ast.new_empty_receiver_node()
	}

	mut mut_tok := token.tok_void
	lpar_tok := p.match_token(.lpar)
	if p.current_token().kind == .key_mut {
		mut_tok = p.match_token(.key_mut)
	}
	name := p.match_token(.name)
	typ := p.parse_type_node(false)
	rpar_tok := p.match_token(.rpar)

	return ast.new_receiver_node(p.syntax_tree, lpar_tok, mut_tok, name, typ, rpar_tok)
}

pub fn (mut p Parser) parse_function() ast.FnDeclNode {
	mut pub_key := token.tok_void

	if p.current_token().kind == .key_pub {
		pub_key = p.match_token(.key_pub)
	}
	fn_key := p.match_token(.key_fn)
	mut receiver := p.parse_receiver()

	expr := p.parse_name_expr()
	name_expr := expr as ast.NameExpr

	lpar_tok := p.match_token(.lpar)
	params := p.parse_fn_params()
	rpar_tok := p.match_token(.rpar)
	ret_type := p.parse_return_type_node()

	if p.current_token().kind == .lcbr {
		block := p.parse_block_stmt()
		return ast.new_fn_decl_node(p.syntax_tree, pub_key, fn_key, receiver, name_expr,
			lpar_tok, params, rpar_tok, ret_type, block as ast.BlockStmt)
	}
	// empty block, some declarations is ok with this, like C
	void_block := ast.new_void_block_stmt(p.syntax_tree)
	return ast.new_fn_decl_node(p.syntax_tree, pub_key, fn_key, receiver, name_expr, lpar_tok,
		params, rpar_tok, ret_type, void_block)
}

fn (mut p Parser) parse_fn_params() ast.SeparatedSyntaxList {
	mut sep_and_nodes := []ast.AstNode{}
	mut parse_next_parameter := true
	for parse_next_parameter && p.current_token().kind != .eof && p.current_token().kind != .rpar {
		param := p.parse_param_node()

		sep_and_nodes << param

		if p.current_token().kind == .comma {
			comma := p.match_token(.comma)
			sep_and_nodes << comma
		} else {
			parse_next_parameter = false
		}
	}
	return ast.new_separated_syntax_list(sep_and_nodes)
}

fn (mut p Parser) parse_return_type_node() ast.TypeNode {
	if p.current_token().kind != .name {
		// this is a procedure without return type
		return ast.new_type_node(p.syntax_tree, token.tok_void, token.tok_void, token.tok_void,
			false)
	}
	mut ref_tok := token.tok_void
	if p.current_token().kind == .amp {
		ref_tok = p.match_token(.amp)
	}
	name := p.match_token(.name)

	if ref_tok == token.tok_void {
		return ast.new_type_node(p.syntax_tree, name, ref_tok, token.tok_void, false)
	} else {
		return ast.new_type_node(p.syntax_tree, name, ref_tok, token.tok_void, true)
	}
}

fn (mut p Parser) parse_param_node() ast.ParamNode {
	mut is_mut := false

	if p.current_token().kind == .key_mut {
		is_mut = true
		p.next_token()
	}
	name := p.match_token(.name)
	if is_mut {
		mut typ := p.parse_type_node(true)
		return ast.new_ref_param_node(p.syntax_tree, name, typ, is_mut)
	} else {
		mut typ := p.parse_type_node(false)
		return ast.new_param_node(p.syntax_tree, name, typ, is_mut)
	}
}

fn (mut p Parser) parse_type_node(parse_ref bool) ast.TypeNode {
	mut ref_tok := token.tok_void
	mut variadic_tok := token.tok_void
	mut is_ref := parse_ref
	if p.current_token().kind == .dot_dot_dot {
		variadic_tok = p.match_token(.dot_dot_dot)
	}
	if p.current_token().kind == .amp {
		ref_tok = p.match_token(.amp)
		is_ref = true
	}
	name := p.match_token(.name)

	return ast.new_type_node(p.syntax_tree, name, ref_tok, variadic_tok, is_ref)
}

// peek, returns a token at offset from current postion
[inline]
fn (mut p Parser) peek_token(offset int) token.Token {
	index := p.pos + offset
	// return last token if index out of range_expr
	if index >= p.tokens.len {
		return p.tokens[p.tokens.len - 1]
	}
	return p.tokens[index]
}

// current returns current token on position
[inline]
fn (mut p Parser) current_token() token.Token {
	return p.peek_token(0)
}

// next returns current token and step to next token
[inline]
fn (mut p Parser) next_token() token.Token {
	current_tok := p.current_token()
	p.pos++
	return current_tok
}

// match_token returns current token if match and move next
fn (mut p Parser) match_token(kind token.Kind) token.Token {
	current_token := p.current_token()

	if current_token.kind == kind {
		return p.next_token()
	}
	p.log.error_expected('token', current_token.kind.str(), kind.str(), current_token.text_location())
	return token.Token{
		kind: kind
		pos: current_token.pos
		lit: ''
		source: p.syntax_tree.source
	}
}

fn (mut p Parser) parse_stmt() ast.Stmt {
	match p.current_token().kind {
		.lcbr {
			return p.parse_block_stmt()
		}
		.key_mut {
			if p.peek_var_decl(1) {
				return p.parse_var_decl_stmt()
			}
			p.log.error_expected_var_decl(p.peek_token(0).text_location())
		}
		.key_if {
			return p.parse_if_stmt()
		}
		.key_for {
			if p.peek_token(1).kind == .name && p.peek_token(2).kind == .key_in {
				// for x in 0..10 {}
				return p.parse_for_range_stmt()
			} else if p.peek_token(1).kind == .lcbr {
				return p.parse_for_stmt(false)
			} else {
				return p.parse_for_stmt(true)
			}
		}
		.key_continue {
			return p.parse_continue_stmt()
		}
		.key_break {
			return p.parse_break_stmt()
		}
		.key_return {
			return p.parse_return_stmt()
		}
		.key_module {
			return p.parse_module_stmt()
		}
		.key_import {
			return p.parse_import_stmt()
		}
		.key_assert {
			return p.parse_assert_stmt()
		}
		.comment {
			return ast.new_comment_stmt(p.syntax_tree, p.current_token())
		}
		.name {
			if p.peek_var_decl(0) {
				return p.parse_var_decl_stmt()
			}
		}
		else {
			return p.parse_expression_stmt()
		}
	}
	return p.parse_expression_stmt()
}

fn (mut p Parser) parse_assert_stmt() ast.Stmt {
	assert_tok := p.match_token(.key_assert)
	expr := p.parse_expr()
	return ast.new_assert_stmt(p.syntax_tree, assert_tok, expr)
}

fn (mut p Parser) parse_module_stmt() ast.Stmt {
	module_tok := p.match_token(.key_module)
	module_name := p.match_token(.name)
	p.syntax_tree.mod = module_name.lit
	return ast.new_module_stmt(p.syntax_tree, module_tok, module_name)
}

fn (mut p Parser) parse_import_stmt() ast.Stmt {
	import_tok := p.match_token(.key_import)
	expr := p.parse_name_expr()
	name_expr := expr as ast.NameExpr
	import_stmt := ast.new_import_stmt(p.syntax_tree, import_tok, name_expr)
	p.syntax_tree.imports << import_stmt
	return import_stmt
}

fn (mut p Parser) parse_return_stmt() ast.Stmt {
	return_tok := p.match_token(.key_return)
	keyword_line_nr := p.source.line_nr(return_tok.pos.pos)
	current_line_nr := p.source.line_nr(p.current_token().pos.pos)
	is_eof := p.current_token().kind == .eof
	same_line := !is_eof && keyword_line_nr == current_line_nr
	if same_line {
		// assume that it is an expression if it
		// starts at the same line as return key word
		expr := p.parse_expr()
		return ast.new_return_with_expr_stmt(p.syntax_tree, return_tok, expr)
	}
	// assume it is am empty return
	return ast.new_return_stmt(p.syntax_tree, return_tok)
}

fn (mut p Parser) parse_continue_stmt() ast.Stmt {
	cont_tok := p.match_token(.key_continue)
	return ast.new_continue_stmt(p.syntax_tree, cont_tok)
}

fn (mut p Parser) parse_break_stmt() ast.Stmt {
	cont_tok := p.match_token(.key_break)
	return ast.new_break_stmt(p.syntax_tree, cont_tok)
}

fn (mut p Parser) parse_for_stmt(has_cond bool) ast.Stmt {
	for_key := p.match_token(.key_for)
	mut cond_expr := if has_cond { p.parse_expr() } else { ast.Expr(ast.new_empty_expr()) }
	body_stmt := p.parse_block_stmt()
	return ast.new_for_stmt(p.syntax_tree, for_key, cond_expr, body_stmt, has_cond)
}

// parse_for_range_stmt, parse for x in 1..10 {}
//		we only allow blocks
fn (mut p Parser) parse_for_range_stmt() ast.Stmt {
	for_key := p.match_token(.key_for)
	ident := p.match_token(.name)
	key_in := p.match_token(.key_in)
	range_expr := p.parse_range_expr()
	stmt := p.parse_block_stmt()

	return ast.new_for_range_stmt(p.syntax_tree, for_key, ident, key_in, range_expr, stmt)
}

fn (mut p Parser) parse_if_stmt() ast.Stmt {
	if_key := p.match_token(.key_if)
	cond_expr := p.parse_expr()
	then_block := p.parse_block_stmt()

	if p.peek_token(0).kind == .key_else {
		else_key := p.match_token(.key_else)
		else_block := p.parse_block_stmt()
		return ast.new_if_else_stmt(p.syntax_tree, if_key, cond_expr, then_block, else_key,
			else_block)
	}

	return ast.new_if_stmt(p.syntax_tree, if_key, cond_expr, then_block)
}

fn (mut p Parser) parse_var_decl_stmt() ast.Stmt {
	mut is_mut := false
	mut mut_tok := token.tok_void
	if p.peek_token(0).kind == .key_mut {
		if p.peek_var_decl(1) {
			// it is a mut assignment
			is_mut = true
			mut_tok = p.match_token(.key_mut)
		}
	}
	ident := p.parse_name_expr()
	op_token := p.match_token(.colon_eq)
	right := p.parse_assign_right_expr()
	decl_stmt := ast.new_var_decl_stmt(p.syntax_tree, mut_tok, ident as ast.NameExpr,
		op_token, right)
	return decl_stmt
}

fn (mut p Parser) parse_block_stmt() ast.Stmt {
	open_brace_token := p.match_token(.lcbr)

	mut stmts := p.parse_multi_stmt()

	close_brace_token := p.match_token(.rcbr)
	return ast.new_block_stmt(p.syntax_tree, open_brace_token, stmts, close_brace_token)
}

[inline]
fn (mut p Parser) parse_multi_stmt() []ast.Stmt {
	mut stmts := []ast.Stmt{}
	for p.peek_token(0).kind != .eof && p.peek_token(0).kind != .rcbr {
		start_tok := p.current_token()
		stmt := p.parse_stmt()
		stmts << stmt
		// if parse stmt did not consume any tokens
		// let's skip it and continue
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
	}
	return stmts
}

[inline]
fn (mut p Parser) parse_expression_stmt() ast.ExprStmt {
	expr := p.parse_expr()
	return ast.new_expr_stmt(p.syntax_tree, expr)
}

fn (mut p Parser) parse_expr() ast.Expr {
	tok := p.current_token()
	match tok.kind {
		.key_if {
			return p.parse_if_expr()
		}
		.name {
			if p.peek_token(1).kind == .eq {
				return p.parse_assign_expr()
			}
		}
		.number {
			// .. range_expr
			if p.peek_token(1).kind == .dot_dot {
				return p.parse_range_expr()
			}
		}
		else {
			return p.parse_assign_expr()
		}
	}
	return p.parse_assign_expr()
}

fn (mut p Parser) parse_range_expr() ast.Expr {
	from_num := p.parse_number_literal()
	range_tok := p.match_token(.dot_dot)
	to_num := p.parse_number_literal()
	return ast.new_range_expr(p.syntax_tree, from_num, range_tok, to_num)
}

fn (mut p Parser) parse_struct_init(name_expr ast.NameExpr) ast.Expr {
	lcbr_tok := p.match_token(.lcbr)
	mut members := []ast.StructInitMemberNode{}
	for p.peek_token(0).kind != .eof && p.peek_token(0).kind != .rcbr {
		start_tok := p.current_token()

		member_name_tok := p.match_token(.name)
		colon_tok := p.match_token(.colon)
		expr := p.parse_expr()

		member := ast.new_init_struct_member_node(p.syntax_tree, member_name_tok, colon_tok,
			expr)
		members << member
		// if parse stmt did not consume any tokens
		// let's skip it and continue
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
	}
	rcbr_tok := p.match_token(.rcbr)

	return ast.new_struct_init_expr(p.syntax_tree, name_expr, lcbr_tok, members, rcbr_tok)
}

// fn (mut p Parser) parse_index_expr() ast.Expr {
// 	lsbr := p.match_token(.lsbr)
// 	expr := p.parse_expr()
// 	rsbr := p.match_token(.rsbr)
// 	return ast.new_index_expr(p.syntax_tree, lsbr, expr, rsbr)
// }
fn (mut p Parser) parse_array_expr() ast.Expr {
	lsbr_tok := p.match_token(.lsbr) //[
	if p.peek_token(0).kind == .rsbr { //] {
		panic('not supported')
	} else {
		mut exprs := []ast.Expr{}
		// parse a value array [1, 2, 3] fixed or non fixed
		for p.peek_token(0).kind != .eof && p.peek_token(0).kind != .rsbr {
			start_tok := p.current_token()

			if p.current_token().kind == .comma {
				p.next_token()
			}
			expr := p.parse_expr()

			exprs << expr
			// if parse stmt did not consume any tokens
			// let's skip it and continue
			if p.current_token() == start_tok {
				// makes sure we not in infinite loop
				p.next_token()
			}
		}
		rsbr_tok := p.match_token(.rsbr)
		if p.peek_token(0).kind == .exl_mark {
			p.next_token()
			return ast.new_value_array_init_expr(p.syntax_tree, lsbr_tok, exprs, rsbr_tok,
				true)
		} else {
			return ast.new_value_array_init_expr(p.syntax_tree, lsbr_tok, exprs, rsbr_tok,
				false)
		}
	}
	panic('not supported')
}

fn (mut p Parser) parse_if_expr() ast.Expr {
	if_key := p.match_token(.key_if)
	cond_expr := p.parse_expr()
	then_block := p.parse_block_stmt()

	else_key := p.match_token(.key_else)
	else_block := p.parse_block_stmt()
	return ast.new_if_expr(p.syntax_tree, if_key, cond_expr, then_block, else_key, else_block)
}

// parse_assign_expr parses an assignment expression
//   can parse nested assignment x=y=10
fn (mut p Parser) parse_assign_expr() ast.Expr {
	if p.peek_assignment(0) {
		ident := p.parse_name_expr()
		op_token := p.match_token(.eq)
		right := p.parse_assign_right_expr()
		return ast.new_assign_expr(p.syntax_tree, ident as ast.NameExpr, op_token, right)
	}
	return p.parse_binary_expr()
}

fn (mut p Parser) parse_assign_right_expr() ast.Expr {
	if p.peek_token(0).kind == .key_if {
		// it is an if expression
		return p.parse_if_expr()
		// } else if p.peek_struct_init(0) {
		// return p.parse_struct_init()
	} else if p.peek_token(0).kind == .lsbr { //[
		return p.parse_array_expr()
	}
	return p.parse_assign_expr()
}

fn (mut p Parser) parse_binary_expr() ast.Expr {
	return p.parse_binary_expr_prec(0)
}

fn (mut p Parser) parse_binary_expr_prec(parent_precedence int) ast.Expr {
	mut left := ast.Expr(ast.new_empty_expr())
	mut tok := p.current_token()

	unary_op_prec := ast.unary_operator_precedence(tok.kind)

	if unary_op_prec != 0 && unary_op_prec >= parent_precedence {
		op_token := p.next_token()
		operand := p.parse_binary_expr_prec(unary_op_prec)
		left = ast.new_unary_expr(p.syntax_tree, op_token, operand)
	} else {
		left = p.parse_primary_expr()
	}

	for {
		tok = p.current_token()
		precedence := ast.binary_operator_precedence(tok.kind)
		if precedence == 0 || precedence <= parent_precedence {
			break
		}
		op_token := p.next_token()
		right := p.parse_binary_expr_prec(precedence)
		if op_token.kind == .lsbr {
			rsbr_tok := p.match_token(.rsbr)
			left = ast.new_index_expr(p.syntax_tree, left, op_token, right, rsbr_tok)
		} else {
			left = ast.new_binary_expr(p.syntax_tree, left, op_token, right)
		}
	}
	return left
}

fn (mut p Parser) parse_primary_expr() ast.Expr {
	tok := p.current_token()
	match tok.kind {
		.lpar {
			return p.parse_parantesize_expr()
		}
		.key_true, .key_false {
			return p.parse_bool_literal()
		}
		.number {
			return p.parse_number_literal()
		}
		.string {
			return p.parse_string_literal()
		}
		else {
			return p.parse_name()
		}
	}
}

fn (mut p Parser) parse_string_literal() ast.Expr {
	string_token := p.match_token(.string)

	return ast.new_literal_expr(p.syntax_tree, string_token, string_token.lit[1..string_token.lit.len - 1])
}

fn (mut p Parser) parse_number_literal() ast.Expr {
	number_token := p.match_token(.number)
	val := strconv.atoi(number_token.lit) or {
		// p.error('Failed to convert number to value <$number_token.lit>')
		0
	}
	return ast.new_literal_expr(p.syntax_tree, number_token, val)
}

fn (mut p Parser) parse_parantesize_expr() ast.Expr {
	left := p.match_token(.lpar)
	expr := p.parse_expr()
	right := p.match_token(.rpar)
	return ast.new_paranthesis_expr(p.syntax_tree, left, expr, right)
}

fn (mut p Parser) parse_bool_literal() ast.Expr {
	is_true := p.current_token().kind == .key_true
	key_tok := p.match_token(if is_true { token.Kind.key_true } else { token.Kind.key_false })
	val := key_tok.kind == .key_true
	return ast.new_literal_expr(p.syntax_tree, key_tok, val)
}

fn (mut p Parser) parse_call_expr(name_expr ast.NameExpr) ast.Expr {
	lpar_tok := p.match_token(.lpar)
	args := p.parse_args()
	rpar_tok := p.match_token(.rpar)
	return ast.new_call_expr(p.syntax_tree, name_expr, lpar_tok, args, rpar_tok)
}

fn (mut p Parser) parse_args() []ast.CallArgNode {
	mut arguments := []ast.CallArgNode{}
	mut parse_next_argument := true
	for parse_next_argument && p.current_token().kind != .eof && p.current_token().kind != .rpar {
		mut mut_tok := token.tok_void
		if p.current_token().kind == .key_mut {
			mut_tok = p.match_token(.key_mut)
		}
		expr := p.parse_expr()
		arguments << ast.new_call_arg_node(p.syntax_tree, mut_tok, expr)

		if p.current_token().kind == .comma {
			p.next_token()
		} else {
			parse_next_argument = false
		}
	}
	return arguments
}

fn (mut p Parser) parse_name() ast.Expr {
	name_expr := p.parse_name_expr()
	if p.current_token().kind == .lpar {
		return p.parse_call_expr(name_expr as ast.NameExpr)
	} else if p.current_token().kind == .lcbr {
		return p.parse_struct_init(name_expr as ast.NameExpr)
	} else {
		return name_expr
	}
}

fn (mut p Parser) parse_name_expr() ast.Expr {
	mut is_c_name := false
	mut ref_token := token.tok_void

	if p.peek_token(0).kind == .amp {
		ref_token = p.match_token(.amp)
	}
	name := p.match_token(.name)
	mut names := [name]
	if p.peek_token(0).kind == .dot {
		if name.lit == 'C' {
			is_c_name = true
		}
		// starts with 'C.'
		for p.peek_token(0).kind != .eof && p.peek_token(0).kind == .dot {
			start_tok := p.current_token()

			p.match_token(.dot)

			if p.peek_token(0).kind != .name {
				break
			}
			n := p.match_token(.name)
			names << n

			// if parse stmt did not consume any tokens
			// let's skip it and continue
			if p.current_token() == start_tok {
				// makes sure we not in infinite loop
				p.next_token()
			}
		}
	}
	return ast.new_ref_name_expr(p.syntax_tree, ref_token, names, is_c_name)
}
