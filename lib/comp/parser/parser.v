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
pub mut:
	log &src.Diagnostics // errors when parsing
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
	ident := p.match_token(.name)
	lcbr_tok := p.match_token(.lcbr)
	params := p.parse_struct_members()
	rcbr_tok := p.match_token(.rcbr)
	struct_ast:= ast.new_struct_decl_node(p.syntax_tree, struct_key, ident, lcbr_tok, 
			params, rcbr_tok)
	println(struct_ast)
	return struct_ast
}

fn (mut p Parser) parse_struct_members() []ast.StructMemberNode {
	mut members := []ast.StructMemberNode{}
	
	for p.current_token().kind != .eof && p.current_token().kind != .rcbr {
		start_tok := p.current_token()
		ident := p.match_token(.name)
		typ := p.match_token(.name)
		if p.current_token() == start_tok {
			// makes sure we not in infinite loop
			p.next_token()
		}
		members << ast.new_struct_member_node(p.syntax_tree, ident, typ)
		
	}
	return members
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
	return ast.new_fn_decl_node(p.syntax_tree, fn_key, ident, lpar_tok, params, rpar_tok,
		ret_type, (fn_block as ast.BlockStmt))
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
		return ast.new_type_node(p.syntax_tree, token.tok_void, false, true)
	}
	mut is_ref := false
	if p.current_token().kind == .amp {
		is_ref = true
		p.next_token()
	}
	name := p.match_token(.name)

	return ast.new_type_node(p.syntax_tree, name, is_ref, false)
}

fn (mut p Parser) parse_param_node() ast.ParamNode {
	mut is_mut := false
	if p.current_token().kind == .key_mut {
		is_mut = true
		p.next_token()
	}
	name := p.match_token(.name)
	typ := p.parse_type_node()
	return ast.new_param_node(p.syntax_tree, name, typ, is_mut)
}

fn (mut p Parser) parse_type_node() ast.TypeNode {
	mut is_ref := false
	if p.current_token().kind == .amp {
		is_ref = true
		p.next_token()
	}
	name := p.match_token(.name)

	return ast.new_type_node(p.syntax_tree, name, is_ref, false)
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

fn (mut p Parser) parse_module_stmt() ast.Stmt {
	module_tok := p.match_token(.key_module)
	module_name := p.match_token(.name)

	return ast.new_module_stmt(p.syntax_tree, module_tok, module_name)
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
	mut cond_expr := if has_cond { p.parse_expr() } else { ast.Expr{} }
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
	return ast.new_var_decl_stmt(p.syntax_tree, ident, op_token, right, is_mut)
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
		ident := p.match_token(.name)
		op_token := p.match_token(.eq)
		right := p.parse_assign_right_expr()
		return ast.new_assign_expr(p.syntax_tree, ident, op_token, right)
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
		left = ast.new_binary_expr(p.syntax_tree, left, op_token, right)
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

fn (mut p Parser) parse_call_expr() ast.Expr {
	ident := p.match_token(.name)
	lpar_tok := p.match_token(.lpar)
	args := p.parse_args()
	rpar_tok := p.match_token(.rpar)
	return ast.new_call_expr(p.syntax_tree, ident, lpar_tok, args, rpar_tok)
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
	return ast.new_name_expr(p.syntax_tree, ident)
}
