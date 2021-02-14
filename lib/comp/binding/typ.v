module binding

type BoundExpr = BoundBinaryExpr | BoundLiteralExpr | BoundUnaryExpression

type BoundNode = BoundExpr

fn (be BoundExpr) typ() Type {
	match be {
		BoundUnaryExpression, BoundBinaryExpr, BoundLiteralExpr {
			return be.typ
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

type Type = int

type LitVal = int | string

fn (l LitVal) typ() Type {
	return match l {
		string {
			1
		}
		int {
			2
		}
	}
}

fn (l LitVal) str() string {
	return match l {
		string {
			l.str()
		}
		int {
			l.str()
		}
	}
}