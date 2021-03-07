module parser

import strconv
import lib.comp.ast
import lib.comp.token
import lib.comp.util

pub struct Parser {
	source &util.SourceText
mut:
	pos    int
	tokens []token.Token
pub mut:
	log &util.Diagnostics // errors when parsing
}

// new_parser_from_text, instance a parser from a text input
fn new_parser_from_text(text string) &Parser {
	source := util.new_source_text(text)
	mut tnz := token.new_tokenizer_from_source(source)
	tokens := tnz.scan_all()
	mut diagnostics := util.new_diagonistics()
	diagnostics.merge(tnz.log)
	mut parser := &Parser{
		source: source
		tokens: tokens
		log: diagnostics
	}
	return parser
}

pub fn (mut p Parser) parse_comp_node() ast.CompNode {
	members := p.parse_members()
	eof := p.match_token(.eof)
	node := ast.new_comp_expr(members, eof)
	return node
}

pub fn (mut p Parser) parse_members() []ast.MemberNode {
	mut members := []ast.MemberNode{}

	for p.peek_token(0).kind != .eof {
		start_tok := p.current_token()
		member := p.parse_member()
		members << member
		// if parse member did not consume any tokens 
		// let's skip it and continue
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
	}
	return members
}

pub fn (mut p Parser) parse_member() ast.MemberNode {
	if p.peek_fn_decl(0) {
		return p.parse_function()
	} else {
		return p.parse_global_stmt()
	}
}

pub fn (mut p Parser) parse_global_stmt() ast.MemberNode {
	stmt := p.parse_stmt()
	return ast.new_glob_stmt(stmt)
}

pub fn (mut p Parser) parse_function() ast.FnDeclNode {
	// mut is_pub := false
	// if p.current_token().kind == .key_pub {
	// 	is_pub = true
	// 	p.next_token()
	// }
	fn_key := p.match_token(.key_fn)
	ident := p.match_token(.name)
	lpar_tok := p.match_token(.lpar)
	params := p.parse_fn_params()
	rpar_tok := p.match_token(.rpar)
	ret_type := p.parse_return_type_node()
	fn_block := p.parse_block_stmt()
	return ast.new_fn_decl_node(fn_key, ident, lpar_tok, params, rpar_tok, ret_type, (fn_block as ast.BlockStmt))
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
	if p.current_token().kind == .lcbr {
		// this is a procedure without return type
		return ast.new_type_node(token.tok_void, false, true)
	}
	mut is_ref := false
	if p.current_token().kind == .amp {
		is_ref = true
		p.next_token()
	}
	name := p.match_token(.name)

	return ast.new_type_node(name, is_ref, false)
}

fn (mut p Parser) parse_param_node() ast.ParamNode {
	mut is_mut := false
	if p.current_token().kind == .key_mut {
		is_mut = true
		p.next_token()
	}
	name := p.match_token(.name)
	typ := p.parse_type_node()
	return ast.new_param_node(name, typ, is_mut)
}

fn (mut p Parser) parse_type_node() ast.TypeNode {
	mut is_ref := false
	if p.current_token().kind == .amp {
		is_ref = true
		p.next_token()
	}
	name := p.match_token(.name)

	return ast.new_type_node(name, is_ref, false)
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
	p.log.error_expected('token', current_token.kind.str(), kind.str(), current_token.pos)
	return token.Token{
		kind: kind
		pos: current_token.pos
		lit: ''
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
			p.log.error_expected_var_decl(p.peek_token(0).pos)
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

// parse_for_range_stmt, parse for x in 1..10 {}
//		we only allow blocks
fn (mut p Parser) parse_for_stmt(has_cond bool) ast.Stmt {
	for_key := p.match_token(.key_for)
	mut cond_expr := if has_cond { p.parse_expr() } else { ast.Expr{} }
	body_stmt := p.parse_block_stmt()
	return ast.new_for_stmt(for_key, cond_expr, body_stmt, has_cond)
}

// parse_for_range_stmt, parse for x in 1..10 {}
//		we only allow blocks
fn (mut p Parser) parse_for_range_stmt() ast.Stmt {
	for_key := p.match_token(.key_for)
	ident := p.match_token(.name)
	key_in := p.match_token(.key_in)
	range_expr := p.parse_range_expr()
	stmt := p.parse_block_stmt()

	return ast.new_for_range_stmt(for_key, ident, key_in, range_expr, stmt)
}

fn (mut p Parser) parse_if_stmt() ast.Stmt {
	if_key := p.match_token(.key_if)
	cond_expr := p.parse_expr()
	then_block := p.parse_block_stmt()

	if p.peek_token(0).kind == .key_else {
		else_key := p.match_token(.key_else)
		else_block := p.parse_block_stmt()
		return ast.new_if_else_stmt(if_key, cond_expr, then_block, else_key, else_block)
	}

	return ast.new_if_stmt(if_key, cond_expr, then_block)
}

fn (mut p Parser) parse_var_decl_stmt() ast.Stmt {
	mut is_mut := false
	if p.peek_token(0).kind == .key_mut {
		if p.peek_var_decl(1) {
			// it is a mut assignment
			is_mut = true
			p.next_token()
		}
	}
	ident := p.match_token(.name)
	op_token := p.match_token(.colon_eq)
	right := p.parse_assign_right_expr()
	return ast.new_var_decl_stmt(ident, op_token, right, is_mut)
}

fn (mut p Parser) parse_block_stmt() ast.Stmt {
	open_brace_token := p.match_token(.lcbr)

	mut stmts := p.parse_multi_stmt()

	close_brace_token := p.match_token(.rcbr)
	return ast.new_block_stmt(open_brace_token, stmts, close_brace_token)
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
	return ast.new_expr_stmt(expr)
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
	return ast.new_range_expr(from_num, range_tok, to_num)
}

fn (mut p Parser) parse_if_expr() ast.Expr {
	if_key := p.match_token(.key_if)
	cond_expr := p.parse_expr()
	then_block := p.parse_block_stmt()

	else_key := p.match_token(.key_else)
	else_block := p.parse_block_stmt()
	return ast.new_if_expr(if_key, cond_expr, then_block, else_key, else_block)
}

// parse_assign_expr parses an assignment expression
//   can parse nested assignment x=y=10
fn (mut p Parser) parse_assign_expr() ast.Expr {
	if p.peek_assignment(0) {
		ident := p.match_token(.name)
		op_token := p.match_token(.eq)
		right := p.parse_assign_right_expr()
		return ast.new_assign_expr(ident, op_token, right)
	}
	return p.parse_binary_expr()
}

fn (mut p Parser) parse_assign_right_expr() ast.Expr {
	if p.peek_token(0).kind == .key_if {
		// it is an if expression
		return p.parse_if_expr()
	}
	return p.parse_assign_expr()
}

fn (mut p Parser) parse_binary_expr() ast.Expr {
	return p.parse_binary_expr_prec(0)
}

fn (mut p Parser) parse_binary_expr_prec(parent_precedence int) ast.Expr {
	mut left := ast.Expr{}
	mut tok := p.current_token()

	unary_op_prec := ast.unary_operator_precedence(tok.kind)

	if unary_op_prec != 0 && unary_op_prec >= parent_precedence {
		op_token := p.next_token()
		operand := p.parse_binary_expr_prec(unary_op_prec)
		left = ast.new_unary_expr(op_token, operand)
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
		left = ast.new_binary_expr(left, op_token, right)
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
			return p.parse_name_or_call_expr()
		}
	}
}

fn (mut p Parser) parse_string_literal() ast.Expr {
	string_token := p.match_token(.string)

	return ast.new_literal_expr(string_token, string_token.lit[1..string_token.lit.len - 1])
}

fn (mut p Parser) parse_number_literal() ast.Expr {
	number_token := p.match_token(.number)
	val := strconv.atoi(number_token.lit) or {
		// p.error('Failed to convert number to value <$number_token.lit>')
		0
	}
	return ast.new_literal_expr(number_token, val)
}

fn (mut p Parser) parse_parantesize_expr() ast.Expr {
	left := p.match_token(.lpar)
	expr := p.parse_expr()
	right := p.match_token(.rpar)
	return ast.new_paranthesis_expr(left, expr, right)
}

fn (mut p Parser) parse_bool_literal() ast.Expr {
	is_true := p.current_token().kind == .key_true
	key_tok := p.match_token(if is_true { token.Kind.key_true } else { token.Kind.key_false })
	val := key_tok.kind == .key_true
	return ast.new_literal_expr(key_tok, val)
}

fn (mut p Parser) parse_call_expr() ast.Expr {
	ident := p.match_token(.name)
	lpar_tok := p.match_token(.lpar)
	args := p.parse_args()
	rpar_tok := p.match_token(.rpar)
	return ast.new_call_expr(ident, lpar_tok, args, rpar_tok)
}

fn (mut p Parser) parse_args() ast.SeparatedSyntaxList {
	mut sep_and_nodes := []ast.AstNode{}
	mut parse_next_argument := true
	for parse_next_argument && p.current_token().kind != .eof && p.current_token().kind != .rpar {
		expr := p.parse_expr()
		sep_and_nodes << expr

		if p.current_token().kind == .comma {
			comma := p.match_token(.comma)
			sep_and_nodes << comma
		} else {
			parse_next_argument = false
		}
	}
	return ast.new_separated_syntax_list(sep_and_nodes)
}

fn (mut p Parser) parse_name_or_call_expr() ast.Expr {
	if p.current_token().kind == .name && p.peek_token(1).kind == .lpar {
		return p.parse_call_expr()
	} else {
		return p.parse_name_expr()
	}
}

fn (mut p Parser) parse_name_expr() ast.Expr {
	ident := p.match_token(.name)
	return ast.new_name_expr(ident)
}
