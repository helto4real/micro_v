module ast

pub struct SeparatedSyntaxList {
mut:
	sep_and_nodes []AstNode
}

pub fn new_separated_syntax_list(sep_and_nodes []AstNode) SeparatedSyntaxList {
	return SeparatedSyntaxList{
		sep_and_nodes: sep_and_nodes
	}
}

pub fn (ssl SeparatedSyntaxList) sep_and_nodes() []AstNode {
	return ssl.sep_and_nodes
}

pub fn (ssl SeparatedSyntaxList) len() int {
	return (ssl.sep_and_nodes.len + 1) / 2
}

pub fn (mut ssl SeparatedSyntaxList) add(expr Expr) {
	ssl.sep_and_nodes << expr
}

pub fn (ssl SeparatedSyntaxList) at(index int) AstNode {
	return ssl.sep_and_nodes[index * 2]
}

pub fn (ssl SeparatedSyntaxList) sep_at(index int) AstNode {
	return ssl.sep_and_nodes[index * 2 + 1]
}
