module ast

import term
import lib.comp.token
import lib.comp.util

// Sumtype statements
type Stmt = BlockStmt | ExprStmt | ForRangeStmt | ForStmt | IfStmt | VarDeclStmt

// Sumtype expressions
pub type Expr = AssignExpr | BinaryExpr | CompNode | IfExpr | LiteralExpr | NameExpr |
	ParaExpr | RangeExpr | UnaryExpr

// Nodes in syntax tree
pub type AstNode = Expr | Stmt | token.Token

pub fn (ex &AstNode) pos() util.Pos {
	match ex {
		Expr, Stmt {
			return ex.pos()
		}
		token.Token {
			return ex.pos
		}
	}
}

pub fn (ex &AstNode) child_nodes() []AstNode {
	match ex {
		Expr { return ex.child_nodes() }
		Stmt { return ex.child_nodes() }
		token.Token { return []AstNode{} }
	}
}

pub fn (ex &AstNode) node_str() string {
	match ex {
		Expr { return ex.node_str() }
		Stmt { return ex.node_str() }
		token.Token { return ex.lit }
	}
}

pub fn (ex &AstNode) tree_print() {
	match ex {
		Expr {
			ex.tree_print()
		}
		Stmt {
			ex.tree_print()
		}
		token.Token {
			println(ex.lit)
		}
	}
}

pub fn (e &Expr) kind() SyntaxKind {
	match e {
		LiteralExpr { return e.kind }
		BinaryExpr { return e.kind }
		UnaryExpr { return e.kind }
		ParaExpr { return e.kind }
		NameExpr { return e.kind }
		AssignExpr { return e.kind }
		CompNode { return e.kind }
		IfExpr { return e.kind }
		RangeExpr { return e.kind }
	}
}

pub fn (ex &Expr) node_str() string {
	match ex {
		LiteralExpr { return ex.node_str() }
		BinaryExpr { return ex.node_str() }
		UnaryExpr { return ex.node_str() }
		ParaExpr { return ex.node_str() }
		NameExpr { return ex.node_str() }
		AssignExpr { return ex.node_str() }
		CompNode { return ex.node_str() }
		IfExpr { return ex.node_str() }
		RangeExpr { return ex.node_str() }
	}
}

pub fn (ex &Expr) child_nodes() []AstNode {
	match ex {
		LiteralExpr { return ex.child_nodes }
		BinaryExpr { return ex.child_nodes }
		UnaryExpr { return ex.child_nodes }
		ParaExpr { return ex.child_nodes }
		NameExpr { return ex.child_nodes }
		AssignExpr { return ex.child_nodes }
		CompNode { return ex.child_nodes }
		IfExpr { return ex.child_nodes }
		RangeExpr { return ex.child_nodes }
	}
}

pub fn (ex &Expr) pos() util.Pos {
	match ex {
		LiteralExpr, BinaryExpr, UnaryExpr, ParaExpr, NameExpr, AssignExpr, CompNode, IfExpr,
		RangeExpr {
			return ex.pos
		}
	}
}

pub fn (ex &Expr) tree_print() {
	match ex {
		LiteralExpr { tree_print(ex) }
		BinaryExpr { tree_print(ex) }
		UnaryExpr { tree_print(ex) }
		ParaExpr { tree_print(ex) }
		NameExpr { tree_print(ex) }
		AssignExpr { tree_print(ex) }
		CompNode { tree_print(ex) }
		IfExpr { tree_print(ex) }
		RangeExpr { tree_print(ex) }
	}
}

pub fn (ex &Stmt) node_str() string {
	match ex {
		BlockStmt { return ex.node_str() }
		ExprStmt { return ex.node_str() }
		VarDeclStmt { return ex.node_str() }
		IfStmt { return ex.node_str() }
		ForRangeStmt { return ex.node_str() }
		ForStmt { return ex.node_str() }
	}
}

pub fn (ex &Stmt) child_nodes() []AstNode {
	match ex {
		BlockStmt { return ex.child_nodes() }
		ExprStmt { return ex.child_nodes() }
		VarDeclStmt { return ex.child_nodes() }
		IfStmt { return ex.child_nodes() }
		ForRangeStmt { return ex.child_nodes() }
		ForStmt { return ex.child_nodes() }
	}
}

pub fn (ex &Stmt) pos() util.Pos {
	match ex {
		BlockStmt, ExprStmt, VarDeclStmt, IfStmt, ForRangeStmt, ForStmt {
			return ex.pos
		}
	}
}

pub fn (ex &Stmt) tree_print() {
	match ex {
		BlockStmt { tree_print(ex) }
		ExprStmt { tree_print(ex) }
		VarDeclStmt { tree_print(ex) }
		IfStmt { tree_print(ex) }
		ForRangeStmt { tree_print(ex) }
		ForStmt { tree_print(ex) }
	}
}

pub interface Node {
	child_nodes() []AstNode
	node_str() string
}

fn tree_print(node &Node) {
	pretty_print_tree(node, '', true)
}

fn pretty_print_tree(node &Node, indent string, is_last bool) {
	marker := if is_last { '└──' } else { '├──' }

	print(term.gray(indent))
	print(term.gray(marker))
	new_ident := indent + if is_last { '   ' } else { '│  ' }

	node_str := node.node_str()

	if node_str[0] == `&` {
		println(term.gray(node_str[5..]))
	} else {
		println(term.bright_cyan(node_str))
	}

	child_nodes := node.child_nodes()
	for i, _ in child_nodes {
		child := child_nodes[i]
		last_node := if i < child_nodes.len - 1 { false } else { true }
		pretty_print_tree(child, new_ident, last_node)
	}
}
