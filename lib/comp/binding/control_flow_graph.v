module binding

import lib.comp.io
import lib.comp.symbols

[heap]
struct BasicBlock {
	is_start bool
	is_end   bool
	id       int
mut:
	stmts    []BoundStmt
	incoming []&BasicBlockBranch
	outgoing []&BasicBlockBranch
}

pub fn new_basic_block(id int) &BasicBlock {
	return &BasicBlock{
		id: id
	}
}

pub fn new_basic_start_block(id int) &BasicBlock {
	return &BasicBlock{
		is_start: true
		is_end: false
		id: id
	}
}

pub fn new_basic_end_block(id int) &BasicBlock {
	return &BasicBlock{
		is_start: false
		is_end: true
		id: id
	}
}

pub fn (mut bb BasicBlock) add_outgoing(branch &BasicBlockBranch) {
	bb.outgoing << branch
}

pub fn (mut bb BasicBlock) add_incoming(branch &BasicBlockBranch) {
	bb.incoming << branch
}

pub fn (ex &BasicBlock) str() string {
	mut b := io.new_node_string_writer()
	if ex.is_start {
		return '<start>'
	}
	if ex.is_end {
		return '<end>'
	}

	for stmt in ex.stmts {
		write_node(b, stmt)
	}
	return b.str()
}

// pub fn (b &BasicBlock) str() string {
// 	if b.is_start {return '<start>'}
// 	if b.is_end {return '<end>'}
// 	// mut writer := io.new_string_writer()
// 	// for stmt in b.stmts {

// 	// }
// }
[heap]
struct BasicBlockBranch {
	from     &BasicBlock
	to       &BasicBlock
	has_expr bool
	cond     BoundExpr
	// id int = 0
}

pub fn (bbb &BasicBlockBranch) str() string {
	if bbb.has_expr == false {
		return ''
	}
	return bbb.cond.str()
}

pub fn new_branch_with_cond_block(from &BasicBlock, to &BasicBlock, cond BoundExpr) &BasicBlockBranch {
	return &BasicBlockBranch{
		to: to
		from: from
		cond: cond
		has_expr: true
	}
}

pub fn new_branch_block(from &BasicBlock, to &BasicBlock) &BasicBlockBranch {
	return &BasicBlockBranch{
		to: to
		from: from
		has_expr: false
	}
}

struct BasicBlockBuilder {
mut:
	block_id int = 2
	blocks   []&BasicBlock
	stmts    []BoundStmt
}

pub fn new_basic_block_builder() &BasicBlockBuilder {
	return &BasicBlockBuilder{}
}

pub fn (mut bbb BasicBlockBuilder) build(block BoundBlockStmt) []&BasicBlock {
	for stmt in block.bound_stmts {
		match stmt {
			BoundBlockStmt {}
			BoundVarDeclStmt {
				bbb.stmts << stmt
			}
			BoundExprStmt {
				bbb.stmts << stmt
			}
			BoundLabelStmt {
				bbb.start_block()
				bbb.stmts << stmt
			}
			BoundCondGotoStmt {
				bbb.stmts << stmt
				bbb.start_block()
			}
			BoundGotoStmt {
				bbb.stmts << stmt
				bbb.start_block()
			}
			BoundReturnStmt {
				bbb.stmts << stmt
				bbb.start_block()
			}
			else {
				panic('unexpected stmt type $stmt')
			}
		}
	}
	bbb.end_block()
	return bbb.blocks
}

pub fn (mut bbb BasicBlockBuilder) start_block() {
	bbb.end_block()
}

pub fn (mut bbb BasicBlockBuilder) end_block() {
	bbb.block_id++
	if bbb.stmts.len > 0 {
		mut block := new_basic_block(bbb.block_id)
		for stmt in bbb.stmts {
			block.stmts << stmt
		}
		bbb.blocks << block
		bbb.stmts.clear()
	}
}

pub fn (mut bbb BasicBlockBuilder) new_start_block() &BasicBlock {
	bbb.block_id++
	return new_basic_start_block(bbb.block_id)
}

pub fn (mut bbb BasicBlockBuilder) new_end_block() &BasicBlock {
	bbb.block_id++
	return new_basic_end_block(bbb.block_id)
}

struct ControlFlowGraph {
	start    &BasicBlock
	end      &BasicBlock
	blocks   []&BasicBlock
	branches []&BasicBlockBranch
}

pub fn create_control_flow_graph(body BoundBlockStmt) &ControlFlowGraph {
	mut basic_block_builder := new_basic_block_builder()
	mut blocks := basic_block_builder.build(body)

	mut graph_builder := new_graph_builder()
	return graph_builder.build_graph(mut blocks)
}

fn new_control_flow_graph(start &BasicBlock, end &BasicBlock, blocks []&BasicBlock, branches []&BasicBlockBranch) &ControlFlowGraph {
	return &ControlFlowGraph{
		start: start
		end: end
		blocks: blocks
		branches: branches
	}
}

fn quote(s string) string {
	return '"' + s.replace('"', '\\"') + '"'
}

// write the graph
pub fn (cfg &ControlFlowGraph) write_to(writer io.TextWriter) ? {
	writer.writeln('digraph G {') ?

	mut block_ids := map[int]string{}
	for block in cfg.blocks {
		id := 'N$block.id'
		block_ids[block.id] = id
	}

	for block in cfg.blocks {
		id := block_ids[block.id]
		label := quote(block.str().replace('\n', '\\l'))
		writer.writeln('    $id [label = $label shape = box]') ?
	}
	for branch in cfg.branches {
		// panic('$cfg')
		from_id := block_ids[branch.from.id]
		to_id := block_ids[branch.to.id]
		label := quote(branch.str())
		writer.writeln('    $from_id -> $to_id [label = $label]') ?
	}
	writer.writeln('}') ?
}

struct GraphBuilder {
mut:
	branches []&BasicBlockBranch
	start    &BasicBlock = new_basic_start_block(1)
	end      &BasicBlock = new_basic_end_block(2)

	block_from_stmt map[voidptr]&BasicBlock
	block_from_label map[string]&BasicBlock
}

pub fn new_graph_builder() &GraphBuilder {
	return &GraphBuilder{}
}

pub fn (mut gb GraphBuilder) connect(mut from BasicBlock, mut to BasicBlock) {
	// panic('test $from.str()')
	branch := new_branch_block(from, to)
	from.add_outgoing(branch)
	to.add_incoming(branch)
	gb.branches << branch
	// panic('branches: $gb.branches')
	// panic('hello: $gb.branches.len')
}

pub fn (mut gb GraphBuilder) connect_cond(mut from BasicBlock, mut to BasicBlock, cond BoundExpr) {
	if cond is BoundLiteralExpr {
		val := cond.val as bool
		if val {
			branch := new_branch_block(from, to)
			from.add_outgoing(branch)
			to.add_incoming(branch)
			gb.branches << branch
			return
		} else {
			return
		}
	}
	branch := new_branch_with_cond_block(from, to, cond)
	from.add_outgoing(branch)
	to.add_incoming(branch)
	gb.branches << branch
}

// pub fn (mut gb GraphBuilder) walk_var_decl_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

// pub fn (mut gb GraphBuilder) walk_expr_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

// pub fn (mut gb GraphBuilder) walk_label_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

// pub fn (mut gb GraphBuilder) walk_cond_goto_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

// pub fn (mut gb GraphBuilder) walk_goto_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

// pub fn (mut gb GraphBuilder) walk_return_stmt(stmt BoundStmt, next BasicBlock, is_last_stmt bool) {
// }

pub fn (mut gb GraphBuilder) negate(expr BoundExpr) BoundExpr {
	
	match expr {
		BoundLiteralExpr {
			val := expr.val as bool
			return new_bound_literal_expr(-val)
		}
		else {
			unary_op := bind_unary_operator(.exl_mark, symbols.bool_symbol) or {panic('unexpected error')}
			return new_bound_unary_expr(unary_op, expr)
		}
	}
}
pub fn (mut gb GraphBuilder) build_graph(mut blocks []&BasicBlock) &ControlFlowGraph {
	// mut basic_block_builder := new_basic_block_builder()
	// mut start := basic_block_builder.new_start_block()
	// mut end := basic_block_builder.new_end_block()

	if blocks.len == 0 {
		gb.connect(mut gb.start, mut gb.end)
	} else {
		// panic('asdasd $blocks')
		gb.connect(mut gb.start, mut blocks[0])
	}

	for block in blocks {
		for stmt in block.stmts {
			gb.block_from_stmt[&stmt] = block
			if stmt is BoundLabelStmt {
				gb.block_from_label[stmt.name] = block
			}
		}
	}

	for i:=0; i< blocks.len; i++ {
		mut current := blocks[i]
		mut next := if i< blocks.len -1 {blocks[i+1]} else {gb.end}
		for i_stmt, stmt in current.stmts {
			// last_stmt := current.stmts.last()
			is_last_stmt := i_stmt == current.stmts.len-1

			match stmt {
				BoundVarDeclStmt {
					if is_last_stmt {
						gb.connect(mut current, mut next)
					}
				}
				BoundExprStmt {
					if is_last_stmt {
						gb.connect(mut current, mut next)
					}
				}
				BoundLabelStmt {
					if is_last_stmt {
						gb.connect(mut current, mut next)
					}	
				}
				BoundCondGotoStmt {
					mut then_block := gb.block_from_label[stmt.label]
					negated_cond := gb.negate(stmt.cond)
					then_cond := if stmt.jump_if_true {stmt.cond} else {negated_cond}
					else_cond := if stmt.jump_if_true {negated_cond} else {stmt.cond}
					mut else_block := next
					gb.connect_cond(mut current, mut then_block, then_cond)			
					gb.connect_cond(mut current, mut else_block, else_cond)			
				}
				BoundGotoStmt {
					mut to_block := gb.block_from_label[stmt.label]
					gb.connect(mut current, mut to_block)
				}
				BoundReturnStmt {
					gb.connect(mut current, mut gb.end)
				}
				else {
					panic('unexpected stmt type $stmt')
				}
			}
		}
	}

	mut new_blocks := []&BasicBlock{cap: blocks.len + 2}
	new_blocks << gb.start
	new_blocks << blocks
	new_blocks << gb.end
	// panic('branches: $gb.branches')
	return new_control_flow_graph(gb.start, gb.end, new_blocks, gb.branches)
}
