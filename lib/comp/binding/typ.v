module binding

import lib.comp.types

type BoundExpr = BoundBinaryExpr | BoundLiteralExpr | BoundUnaryExpression

type BoundNode = BoundExpr

fn (be BoundExpr) typ() types.Type {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr {
			return be.typ
		}
	}
}

fn (be BoundExpr) typ_str() string {
	match be {
		BoundLiteralExpr {
			return types.built_in_types[int(be.typ)]
		}
		BoundUnaryExpression, BoundBinaryExpr {
			return be.typ.str()
		}
	}
}

fn (be BoundExpr) kind() BoundNodeKind {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr {
			return be.kind
		}
	}
}
