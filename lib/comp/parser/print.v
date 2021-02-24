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
		ast.Expr {
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
				ast.CompNode {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.IfExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.RangeExpr {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}				
				}
			}
		}
		ast.Stmt {
			match node {
				ast.BlockStmt {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.ExprStmt {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.VarDeclStmt {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.IfStmt {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.ForRangeStmt {
					println(term.gray('$node.kind'))
					child_nodes := node.child_nodes()
					for i, child in child_nodes {
						last_node := if i < child_nodes.len - 1 { false } else { true }
						pretty_print(child, new_ident, last_node)
					}
				}
				ast.ForStmt {
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
