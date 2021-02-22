module parser

import term
import lib.comp.ast
import lib.comp.token

pub fn pretty_print(node ast.AstNode, ident string, is_last bool) {
	marker := if is_last { '└──' } else { '├──' }

	print(term.gray(ident))
	print(term.gray(marker))
	new_ident := ident + if is_last { '   ' } else { '│  ' }
	match node {
		ast.ExpressionSyntax {
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
				ast.ComplationSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.IfExprSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
			}
		}
		ast.StatementSyntax {
			match node {
				ast.BlockStatementSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.ExpressionStatementSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.VarDeclStmtSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.IfStmtSyntax {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
			}
		}
		token.Token {
			print(term.gray('$node.kind:'))
			println(term.bright_cyan('$node.lit'))
		}
	}
}
