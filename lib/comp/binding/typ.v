module binding

import lib.comp.types

type BoundExpr = BoundBinaryExpr | BoundLiteralExpr | BoundUnaryExpression | BoundVariableExpr | BoundAssignExpr

type BoundNode = BoundExpr

pub fn (be BoundExpr) typ() types.Type {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr,
		BoundAssignExpr{
			return be.typ
		}
	}
}

pub fn (be BoundExpr) typ_str() string {
	match be {
		BoundLiteralExpr {
			return types.built_in_types[int(be.typ)]
		}
		BoundUnaryExpression, BoundBinaryExpr, BoundVariableExpr, BoundAssignExpr {
			return types.built_in_types[int(be.typ)]
		}
	}
}

pub fn (be BoundExpr) kind() BoundNodeKind {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr, BoundVariableExpr, BoundAssignExpr {
			return be.kind
		}
	}
}
