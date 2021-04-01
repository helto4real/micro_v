
	module golang

	import lib.comp.binding as bi
	import lib.comp.symbols

	// The for range is transformed it two stages, this stage transforms it
	// to a normal for statement and then to a golan while statement in code gen

	// for <var> in <lower>..<upper>
	//      <body>
	//
	// ----->
	// {
	//   mut index := <lower>
	//   upper := <upper>
	//   for index < upper {
	//      <body>
    //		index = index + 1 
	//	 }
	// }

fn lower_for_range(for_range_stmt bi.BoundForRangeStmt) []bi.BoundStmt {
	
	mut stmts := []bi.BoundStmt{}

	range := for_range_stmt.range_expr as bi.BoundRangeExpr
	
	// mut index := lower
	index_decl := bi.var_decl(for_range_stmt.ident, range.from_exp, true)
	// upper := upper
	upper_decl := bi.var_decl_local('upper', symbols.int_symbol, range.to_exp, false)

	stmts << index_decl
	stmts << upper_decl

	// add a ending statement that will increase the index
	for_body := for_range_stmt.body_stmt as bi.BoundBlockStmt
	mut body_stmts := []bi.BoundStmt{cap: for_body.stmts.len+1}
	
	body_stmts << for_body.stmts
	// i = i + 1
	body_stmts << bi.increment(bi.variable(index_decl))

	// for_range_stmt.body_stmt
	for_stmt := bi.@for(
		bi.less_than(bi.variable(index_decl), bi.variable(upper_decl)),
		bi.new_bound_block_stmt(body_stmts),
		true
	)

	stmts << for_stmt
	return stmts
}