module ast

import lib.comp.token
import lib.comp.util.source as src

fn test_number_syntax_kind() {
	assert new_literal_expr(&SyntaxTree(0), token.Token{ kind: .number source: &src.SourceText(0) }, 0).kind == .literal_expr
}

fn test_binary_syntax_kind() {
	assert new_binary_expr(&SyntaxTree(0), new_literal_expr(&SyntaxTree(0), token.Token{
		kind: .number source: &src.SourceText(0)
	}, 0), token.Token{
		kind: .plus source: &src.SourceText(0)
	}, new_literal_expr(&SyntaxTree(0), token.Token{ kind: .number source: &src.SourceText(0) }, 0)).kind == .binary_expr
}
