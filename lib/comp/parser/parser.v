module parser

import term
import strconv
import lib.comp.ast
import lib.comp.token
import lib.comp.util

pub struct Parser {
	text string
mut:
	pos    int
	tokens []token.Token
pub mut:
	log util.Diagnostics // errors when parsing
}

pub fn parse_syntax_tree(text string) SyntaxTree {
	mut parser := new_parser_from_text(text)
	return parser.parse()
}

// new_parser_from_text, instance a parser from a text input
fn new_parser_from_text(text string) &Parser {
	mut tnz := token.new_tokenizer_from_string(text)
	tokens := tnz.scan_all()
	mut diagnostics := util.new_diagonistics()
	diagnostics.merge(tnz.log)
	mut parser := &Parser{
		text: text
		tokens: tokens
		log: diagnostics
	}
	return parser
}

pub fn (mut p Parser) parse() SyntaxTree {
	expr := p.parse_expr()
	eof := p.match_token(.eof)
	return new_syntax_tree(p.log, expr, eof)
}

// peek, returns a token at offset from current postion
[inline]
fn (mut p Parser) peek_token(offset int) token.Token {
	index := p.pos + offset
	// return last token if index out of range
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

pub fn pretty_print(node ast.AstNode, ident string, is_last bool) {
	marker := if is_last { '└──' } else { '├──' }

	print(term.gray(ident))
	print(term.gray(marker))
	new_ident := ident + if is_last { '   ' } else { '│  ' }
	match node {
		ast.Expression {
			match node {
				// bug prevents me from colapsing
				ast.BinaryExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.UnaryExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.LiteralExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.NameExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.AssignExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.ParaExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.EmptyExpr {
					panic('None expression should never exist!')
				}
			}
		}
		token.Token {
			print(term.gray('$node.kind:'))
			println(term.bright_cyan('$node.lit'))
		}
	}
}

[inline]
fn (mut p Parser) parse_expr() ast.Expression {
	return p.parse_assign_expr()
}

// parse_assign_expr parses an assignment expression
//   can parse nested assignment x=y=10
fn (mut p Parser) parse_assign_expr() ast.Expression {
	mut is_mut := false
	if p.peek_token(0).kind == .key_mut {
		if p.peek_assignment(1) {
			// it is a mut assignment
			is_mut = true
			p.next_token()
		}
	}
	if p.peek_assignment(0) {
		ident_tok := p.next_token()
		op_token := p.next_token()
		right := p.parse_assign_expr()
		return ast.new_assign_expr(ident_tok, is_mut, op_token, right)
	}
	return p.parse_binary_expr()
}

fn (mut p Parser) parse_binary_expr() ast.Expression {
	return p.parse_binary_expr_prec(0)
}

fn (mut p Parser) parse_binary_expr_prec(parent_precedence int) ast.Expression {
	mut left := ast.Expression(ast.EmptyExpr{})
	mut tok := p.current_token()

	unary_op_prec := unary_operator_precedence(tok.kind)

	if unary_op_prec != 0 && unary_op_prec >= parent_precedence {
		op_token := p.next_token()
		operand := p.parse_binary_expr_prec(unary_op_prec)
		left = ast.new_unary_expr(op_token, operand)
	} else {
		left = p.parse_primary_expr()
	}

	for {
		tok = p.current_token()
		precedence := binary_operator_precedence(tok.kind)
		if precedence == 0 || precedence <= parent_precedence {
			break
		}
		op_token := p.next_token()
		right := p.parse_binary_expr_prec(precedence)
		left = ast.new_binary_expr(left, op_token, right)
	}
	return left
}

fn (mut p Parser) parse_primary_expr() ast.Expression {
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
		else {
			return p.parse_name_expr()
		}
	}
}

fn (mut p Parser) parse_number_literal() ast.Expression {
	number_token := p.match_token(.number)
	val := strconv.atoi(number_token.lit) or {
		// p.error('Failed to convert number to value <$number_token.lit>')
		0
	}
	return ast.new_literal_expr(number_token, val)
}

fn (mut p Parser) parse_parantesize_expr() ast.Expression {
	left := p.match_token(.lpar)
	expr := p.parse_expr()
	right := p.match_token(.rpar)
	return ast.new_paranthesis_expr(left, expr, right)
}

fn (mut p Parser) parse_bool_literal() ast.Expression {
	is_true := p.current_token().kind == .key_true
	key_tok := p.match_token(if is_true { token.Kind.key_true } else { token.Kind.key_false })
	val := key_tok.kind == .key_true
	return ast.new_literal_expr(key_tok, val)
}

fn (mut p Parser) parse_name_expr() ast.Expression {
	ident_tok := p.match_token(.name)
	return ast.new_name_expr(ident_tok)
}
