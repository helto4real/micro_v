module emit

import lib.comp.gen.llvm.core
import lib.comp.binding
import lib.comp.symbols
import lib.comp.util.source
import lib.comp.token

fn (mut fd FunctionDecl) emit_expr(node binding.BoundExpr) core.Value {
	match node {
		binding.BoundConvExpr { return fd.emit_convert_expr(node) }
		binding.BoundLiteralExpr { return fd.emit_literal_expr(node) }
		binding.BoundBinaryExpr { return fd.emit_binary_expr(node) }
		binding.BoundVariableExpr { return fd.emit_variable_expr(node) }
		binding.BoundUnaryExpr { return fd.emit_unary_expr(node) }
		binding.BoundCallExpr { return fd.emit_call_expr(node) }
		binding.BoundStructInitExpr { return fd.emit_struct_init_expr(node) }
		binding.BoundArrayInitExpr { return fd.emit_array_init_expr(node) }
		binding.BoundIndexExpr { return fd.emit_array_index_expr(node) }
		binding.BoundIfExpr { return fd.emit_if_expr(node) }
		binding.BoundAssignExpr { return fd.emit_assignment_expr(node) }
		else { panic('unexpected expr: $node.kind') }
	}
}

fn (mut fd FunctionDecl) emit_stmt(node binding.BoundStmt) {
	match node {
		binding.BoundReturnStmt {
			if node.has_expr {
				val := fd.emit_expr(node.expr)
				fd.bld.create_ret(val)
			} else {
				fd.bld.create_ret_void()
			}
		}
		binding.BoundVarDeclStmt {
			fd.emit_var_decl(node)
		}
		binding.BoundAssertStmt {
			fd.emit_assert_stmt(node)
		}
		binding.BoundExprStmt {
			fd.last_val = fd.emit_expr(node.expr)
		}
		binding.BoundLabelStmt {
			fd.emit_label_stmt(node)
		}
		binding.BoundCondGotoStmt {
			fd.emit_cond_goto_stmt(node)
		}
		binding.BoundCommentStmt {} // Ignore comments
		binding.BoundImportStmt {} // Ignore imports
		binding.BoundModuleStmt {} // Ignore modules
		binding.BoundGotoStmt {
			fd.emit_goto_stmt(node)
		}
		binding.BoundBlockStmt {
			for stmt in node.stmts {
				fd.emit_stmt(stmt)
			}
		}
		else {
			panic('unexepected unsupported statement $node.kind')
		}
	}
}

fn (mut fd FunctionDecl) emit_cond_goto_stmt(node binding.BoundCondGotoStmt) {
	cond_expr := node.cond_expr
	cond_expr_val := fd.emit_expr(cond_expr)

	eq_block := fd.blocks[node.true_label]
	not_eq_block := fd.blocks[node.false_label]

	fd.bld.create_cond_br(cond_expr_val, eq_block, not_eq_block)
}

fn (mut fd FunctionDecl) emit_label_stmt(node binding.BoundLabelStmt) {
	label_block := fd.blocks[node.name]

	// Check if last instruction is terminator, only
	// if it is not terminated last instruction
	// we add a goto statement
	last_instruction := fd.current_block.last_instruction()
	if !last_instruction.isnil() {
		is_term_instr := last_instruction.is_a_terminator_instruction()
		if is_term_instr.isnil() {
			// No terminator instruction
			// we need to add a branch to next block
			fd.bld.create_br(label_block)
		}
	}

	fd.current_block = label_block
	fd.bld.position_at_end(label_block)
}

fn (mut fd FunctionDecl) emit_goto_stmt(node binding.BoundGotoStmt) {
	goto_block := fd.blocks[node.label]
	println('GOTO $node.label')
	fd.bld.create_br(goto_block)
}

fn (mut fd FunctionDecl) emit_var_decl(node binding.BoundVarDeclStmt) {
	var_typ := node.var.typ
	var_name := node.var.name

	mut typ := fd.em.get_ref_type_from_type_symb(var_typ)

	expr_val := fd.emit_expr(node.expr)
	var_val := fd.bld.alloca_and_store(typ, expr_val, var_name)
	fd.em.var_decl[node.var.id] = var_val
}

fn (mut fd FunctionDecl) emit_assert_stmt(node binding.BoundAssertStmt) {
	//   branch <cond> continue: else assert:
	// assert:
	//   printf <assert inormation>
	//   setjmp()
	// continue:
	// 	 <rest_of_body>
	cond_expr := node.expr
	expr_val := fd.emit_expr(cond_expr)
	cont_expr_val := fd.dereference_if_ref(&cond_expr, expr_val)

	assert_block := fd.ctx.new_basic_block(fd.val, 'assert')
	continue_block := fd.ctx.new_basic_block(fd.val, 'assert_cont')

	assert_block.move_after(fd.current_block)
	continue_block.move_after(assert_block)

	fd.bld.create_cond_br(cont_expr_val, continue_block, assert_block)
	fd.bld.position_at_end(assert_block)

	// insert to print assert information
	mut sw := source.SourceWriter{}
	source.write_diagnostic(mut sw, node.location, 'assert error', 1)
	fd.println(sw.str())

	// then do longjmp to exit
	fd.emit_call_builtin('C.longjmp', fd.em.global_const[GlobalVarRefType.jmp_buff], fd.ctx.c_i64(1,
		true))

	fd.bld.create_unreachable()

	fd.bld.position_at_end(continue_block)
}

fn (mut fd FunctionDecl) println(text string) {
	lit_expr := binding.new_bound_literal_expr(text) as binding.BoundLiteralExpr
	lit_expr_val := fd.emit_literal_expr(lit_expr)

	if text.len > 0 {
		fd.emit_call_builtin('C.printf', fd.em.get_global_string(.printf_str_nl), lit_expr_val)
	} else {
		// empty string
		fd.emit_call_builtin('C.printf', fd.em.get_global_string(.nl))
	}
}

fn (mut fd FunctionDecl) emit_variable_expr(node binding.BoundVariableExpr) core.Value {
	var_typ := node.var.typ
	typ_ref := fd.em.get_type_from_type_symb(var_typ)
	mut var := fd.em.var_decl[node.var.id] or {
		panic('unexpected, variable not declared: $node.var.name')
	}
	mut current_typ_ref := typ_ref
	mut current_typ := var_typ
	mut current_name := ''
	if var_typ is symbols.StructTypeSymbol {
		if node.names.len > 0 {
			mut indicies := [fd.ctx.c_i32(0, false)]

			for i, name in node.names {
				if i == 0 {
					continue
				}
				current_name = name.lit
				idx := current_typ.lookup_member_index(name.lit)
				current_typ = current_typ.lookup_member_type(name.lit)
				current_typ_ref = fd.em.get_type_from_type_symb(current_typ)
				if idx < 0 {
					panic('unexepected, lookup member $name, resultet in error')
				}
				indicies << fd.ctx.c_i32(idx, false)
			}
			kind := var.value_kind()
			typ_kind := var.typ().type_kind()

			if node.var.is_ref && kind != .argument {
				if typ_kind == .pointer {
					if var.typ().element_type().type_kind() == .pointer {
						var = fd.bld.create_load2(typ_ref.to_pointer_type(0), var)
					}
				} else {
					var = fd.bld.create_load2(typ_ref.to_pointer_type(0), var)
				}
			}
			val := fd.bld.create_gep2(typ_ref, var, indicies)

			if kind != .argument {
				loaded_val := fd.bld.create_named_load2(current_typ_ref, val, 'var_expr')
				return loaded_val
			}
			return val
			// 	if current_typ.is_ref { //
			// 		return val
			// 	}

			// 	println('LOADING: $node.var->$current_name : $current_typ ($current_typ.is_ref)')
			// 	loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, current_typ_ref,
			// 		val, no_name.str)

			// 	return loaded_var
		}
	}
	if node.var.is_ref || node.typ.is_ref || node.typ.kind == .array_symbol {
		return var
	}
	loaded_var := fd.bld.create_load2(typ_ref, var)
	return loaded_var
}

fn (mut fd FunctionDecl) emit_assignment_expr(node binding.BoundAssignExpr) core.Value {
	expr_ref := fd.emit_expr(node.expr)
	var := node.var
	mut ref_var := fd.em.var_decl[var.id]

	typ := var.typ
	if typ is symbols.StructTypeSymbol && node.names.len > 0 {
		ref_var = fd.get_reference_to_element(ref_var, typ, node.names, node.expr.typ.is_ref)
	}
	fd.bld.create_store(expr_ref, ref_var)
	return ref_var
}

fn (mut fd FunctionDecl) get_reference_to_element(var_ref core.Value, struct_symbol symbols.TypeSymbol, names []token.Token, is_ref bool) core.Value {
	typ_ref := fd.em.get_type_from_type_symb(struct_symbol)
	mut current_typ := struct_symbol
	mut indicies := [fd.ctx.c_i32(0, false)]

	for i, name in names {
		if i == 0 {
			continue
		}
		idx := current_typ.lookup_member_index(name.lit)
		current_typ = current_typ.lookup_member_type(name.lit)
		if idx < 0 {
			panic('unexepected, lookup member $name, resultet in error')
		}
		indicies << fd.ctx.c_i32(idx, false)
	}
	// if is_ref {
	// 	var_ref_to_use = C.LLVMBuildLoad2(c.mod.builder.builder_ref, typ_ref, var_ref_to_use, no_name.str)
	// }
	return fd.bld.create_gep2(typ_ref, var_ref, indicies)
}

fn (mut fd FunctionDecl) emit_if_expr(node binding.BoundIfExpr) core.Value {
	cond_expr_ref := fd.emit_expr(node.cond_expr)

	// Create the temporary variable that will store the result
	// in the then_block and else_block	
	merge_var := fd.bld.create_alloca(fd.em.get_type_from_type_symb(node.typ), '')

	then_block := fd.ctx.new_basic_block(fd.val, 'then_block')
	else_block := fd.ctx.new_basic_block(fd.val, 'else_block')
	result_block := fd.ctx.new_basic_block(fd.val, 'result_block')

	then_block.move_after(fd.current_block)
	else_block.move_after(then_block)

	fd.bld.create_cond_br(cond_expr_ref, then_block, else_block)

	// handle the logic for then block
	fd.bld.position_at_end(then_block)
	fd.current_block = then_block
	fd.emit_stmt(node.then_stmt)
	then_block_val_ref := fd.last_val
	fd.bld.create_store(then_block_val_ref, merge_var)
	fd.bld.create_br(result_block)

	// handle the logic for then block
	fd.bld.position_at_end(else_block)
	fd.current_block = else_block
	fd.emit_stmt(node.else_stmt)
	else_block_val_ref := fd.last_val
	fd.bld.create_store(else_block_val_ref, merge_var)
	fd.bld.create_br(result_block)

	fd.bld.position_at_end(result_block)
	return fd.bld.create_load2(fd.em.get_type_from_type_symb(node.typ), merge_var)
}

fn (mut fd FunctionDecl) emit_call_expr(node binding.BoundCallExpr) core.Value {
	match node.func.name {
		'println', 'print' {
			glob_print_str := if node.func.name == 'print' {
				fd.em.get_global_string(GlobalVarRefType.printf_str)
			} else {
				fd.em.get_global_string(GlobalVarRefType.printf_str_nl)
			}
			param := fd.emit_expr(node.params[0])

			return fd.emit_call_builtin('C.printf', glob_print_str, param)
		}
		'exit' {
			param := fd.emit_expr(node.params[0])
			return fd.emit_call_builtin('C.exit', param)
		}
		else {}
	}
	return fd.emit_call_fn(node)
}

fn (mut fd FunctionDecl) emit_struct_init_expr(si binding.BoundStructInitExpr) core.Value {
	typ_ref := fd.em.get_type_from_type_symb(si.typ)
	mut value_refs := []core.Value{}
	for member in si.members {
		value_refs << fd.emit_expr(member.expr)
	}
	return typ_ref.create_const_named_struct(value_refs)
}

fn (mut fd FunctionDecl) emit_convert_expr(node binding.BoundConvExpr) core.Value {
	expr := node.expr
	expr_val_ref := fd.emit_expr(expr)
	from_typ := expr.typ
	to_typ := node.typ
	match from_typ {
		symbols.BuiltInTypeSymbol {
			match from_typ.kind {
				.string_symbol {
					match to_typ.kind {
						.struct_symbol {
							if to_typ.name == 'String' {
								if node.expr is binding.BoundLiteralExpr {
									val := node.expr.const_val.val as string

									return fd.emit_lit_to_string(expr_val_ref, val.len)
								} else {
									return fd.emit_lit_to_string(expr_val_ref, 0) ///c.cstr_to_string(expr_val_ref)
								}
							}
						}
						else {
							panic('convertion from byte to $to_typ.name is not supported yet')
						}
					}
				}
				.byte_symbol {
					match to_typ.kind {
						.char_symbol {
							return expr_val_ref
						}
						else {
							panic('convertion from byte to $to_typ.name is not supported yet')
						}
					}
				}
				.char_symbol {
					match to_typ.kind {
						.byte_symbol {
							return expr_val_ref
						}
						else {
							panic('convertion from char to $to_typ.name is not supported yet')
						}
					}
				}
				.i64_symbol {
					match to_typ.kind {
						.string_symbol {
							fd.cast_int_to_string(&node.expr, expr_val_ref)
						}
						else {}
					}
					panic('convertion from i64 to $to_typ.name is not supported yet')
				}
				.int_symbol {
					match to_typ.kind {
						.string_symbol {
							return fd.cast_int_to_string(&node.expr, expr_val_ref)
						}
						.struct_symbol {
							mut to_typ_ref := fd.em.get_type_from_type_symb(to_typ)
							if to_typ.is_ref {
								to_typ_ref = to_typ_ref.to_pointer_type(0)
							}
							return fd.bld.create_int_to_ptr(expr_val_ref, to_typ_ref)
						}
						.i64_symbol {
							mut to_typ_ref := fd.em.get_type_from_type_symb(to_typ)
							return fd.bld.create_int_cast(expr_val_ref, to_typ_ref, false)
						}
						else {
							panic('convertion from int to $to_typ.name is not supported yet')
						}
					}
				}
				.bool_symbol {
					match to_typ.kind {
						.string_symbol {
							// CondBr <expr> true_block, false_block
							// true_block:
							//	 %res_var = 'true'
							//   Br %result_block
							// false_block:
							//   %res_var = 'true'
							//   Br %result_block
							// result_block:
							// 	 load %res_var

							// get the global strings for 'true' and 'false'
							glob_str_true := fd.em.get_global_string(GlobalVarRefType.str_true)
							glob_str_false := fd.em.get_global_string(GlobalVarRefType.str_false)

							res_var := fd.bld.create_alloca(fd.em.get_type_from_type_symb(to_typ),
								'')

							// true_block := fd.ctx.insert_basic_block(fd.current_block, '')
							true_block := fd.ctx.new_basic_block(fd.val, '')
							// false_block := fd.ctx.insert_basic_block(true_block, '')
							false_block := fd.ctx.new_basic_block(fd.val, '')

							result_block := fd.ctx.new_basic_block(fd.val, '')

							true_block.move_after(fd.current_block)
							false_block.move_after(true_block)
							fd.bld.create_cond_br(expr_val_ref, true_block, false_block)

							// handle the logic for then block
							fd.bld.position_at_end(true_block)
							fd.current_block = true_block
							fd.bld.create_store(glob_str_true, res_var)
							fd.bld.create_br(result_block)

							// handle the logic for then block
							fd.bld.position_at_end(false_block)
							fd.current_block = false_block
							fd.bld.create_store(glob_str_false, res_var)
							fd.bld.create_br(result_block)

							// hanlde the logic for result block
							fd.bld.position_at_end(result_block)
							return fd.bld.create_load2(fd.em.get_type_from_type_symb(to_typ),
								res_var)
						}
						else {
							panic('convertion from bool to $to_typ.name is not supported yet')
						}
					}
				}
				else {
					panic('from type $from_typ.name conversion not supported yet')
				}
			}
		}
		symbols.StructTypeSymbol {
			if from_typ.name == 'String' {
				if to_typ.kind == .string_symbol {
					return fd.emit_string_from_lit(expr_val_ref)
				}
			}
		}
		else {
			panic('from type $from_typ conversion not supported yet')
		}
	}
	panic('from type $from_typ conversion not supported yet')
}

fn (mut fd FunctionDecl) cast_int_to_string(int_expr &binding.BoundExpr, int_val core.Value) core.Value {
	glob_num_println := fd.em.get_global_string(GlobalVarRefType.printf_num)

	cast := fd.bld.create_ptr_cast(fd.em.global_const[GlobalVarRefType.sprintf_buff],
		fd.ctx.int8_type().to_pointer_type(0))
	fd.emit_call_builtin('C.sprintf', cast, glob_num_println, int_val) // fd.dereference_if_ref(int_expr, int_val)

	return cast
}

fn (mut fd FunctionDecl) emit_string_from_lit(str_struct core.Value) core.Value {
	// emit a string struct from a string literal
	string_typ_ref := fd.em.types['String']

	merge_var := fd.bld.alloca_and_store(string_typ_ref, str_struct, '')
	// str is the first index
	mut indicies := [
		fd.ctx.c_i32(0, false),
		fd.ctx.c_i32(0, false),
	]
	ref_ptr := fd.bld.create_gep2(string_typ_ref, merge_var, indicies)

	typ_ref_i8_ptr := core.int8_type().to_pointer_type(0)
	return fd.bld.create_load2(typ_ref_i8_ptr, ref_ptr)
}

fn (mut fd FunctionDecl) emit_lit_to_string(str_lit core.Value, len int) core.Value {
	// emit a string struct from a string literal
	string_typ_ref := fd.em.types['String']
	mut value_refs := []core.Value{}

	value_refs << str_lit // &char  str
	value_refs << fd.ctx.c_i32(len, false)
	value_refs << fd.ctx.c_i32(0, false)
	return string_typ_ref.create_const_named_struct(value_refs)
}

// // just put a copy on the stack for now
// fn (mut fd FunctionDecl) cstr_to_string(str_lit &C.LLVMValueRef) &C.LLVMValueRef {
// 	println('CSTRING START')
// 	// emit a string struct from a string literal
// 	//calculate lenght
// 	ptr_to_cstr := C.LLVMBuildPointerCast(c.mod.builder.builder_ref,
// 		str_lit, C.LLVMPointerType(C.LLVMInt8TypeInContext(c.mod.ctx_ref),
// 		0), no_name.str)

// 	// call strlen
// 	mut cb := c.new_builtin_call('strlen')
// 	cb.add_param(ptr_to_cstr)
// 	len_ref := cb.emit()

// 	// new_str_array_typ := C.LLVMArrayType(C.LLVMInt8TypeInContext(c.mod.ctx_ref),
// 	// 	0), unsigned ElementCount);	
// 	arr_alloc := C.LLVMBuildArrayAlloca(c.mod.builder.builder_ref, C.LLVMInt8TypeInContext(c.mod.ctx_ref),
//                                   len_ref, no_name.str)

// 	string_typ_ref := c.mod.types['String']
// 	mut value_refs := []&C.LLVMValueRef{}

// 	value_refs << arr_alloc // &char  str
// 	value_refs <<  len_ref// len    int
// 	// is_lit int
// 	value_refs << C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), 0, bool_to_llvm_bool(false))
// 	res := C.LLVMConstNamedStruct(string_typ_ref, value_refs.data, value_refs.len)
// 	println('CSTRING end')
// 	return res
// }

fn (mut fd FunctionDecl) emit_array_index_expr(node binding.BoundIndexExpr) core.Value {
	var_ref := fd.emit_expr(node.left_expr)
	index_ref := fd.emit_expr(node.index_expr)
	arr_typ := node.left_expr.typ as symbols.ArrayTypeSymbol
	typ_ref := fd.em.get_type_from_type_symb(arr_typ)
	elem_typ_ref := fd.em.get_type_from_type_symb(arr_typ.elem_typ)
	mut indicies := [fd.ctx.c_i32(0, false), index_ref]

	gep_val_ref := fd.bld.create_gep2(typ_ref, var_ref, indicies)
	return fd.bld.create_load2(elem_typ_ref, gep_val_ref)
}

fn (mut fd FunctionDecl) emit_array_init_expr(ai binding.BoundArrayInitExpr) core.Value {
	arr_typ := ai.typ as symbols.ArrayTypeSymbol
	typ_ref := fd.em.get_type_from_type_symb(arr_typ.elem_typ)
	mut value_refs := []core.Value{}
	for expr in ai.exprs {
		value_refs << fd.emit_expr(expr)
	}
	return typ_ref.create_const_array(value_refs)
}

fn (mut fd FunctionDecl) emit_unary_expr(unary_expr binding.BoundUnaryExpr) core.Value {
	operand_expr_val_ref := fd.emit_expr(unary_expr.operand_expr)
	match unary_expr.op.op_kind {
		.negation {
			return fd.bld.create_neg(operand_expr_val_ref)
		}
		.logic_negation {
			return fd.bld.create_not(operand_expr_val_ref)
		}
		else {
			panic('unary operation $unary_expr ($unary_expr.op.op_kind) not supported')
		}
	}
}

fn (mut fd FunctionDecl) emit_binary_expr(binary_expr binding.BoundBinaryExpr) core.Value {
	left_val := fd.dereference_if_ref(&binary_expr.left_expr, fd.emit_expr(binary_expr.left_expr))
	right_val := fd.dereference_if_ref(&binary_expr.right_expr, fd.emit_expr(binary_expr.right_expr))

	match binary_expr.op.op_kind {
		.addition {
			return fd.bld.create_bin_op(.llvm_add, left_val, right_val)
		}
		.subraction {
			return fd.bld.create_bin_op(.llvm_sub, left_val, right_val)
		}
		.multiplication {
			return fd.bld.create_bin_op(.llvm_mul, left_val, right_val)
		}
		.divition {
			return fd.bld.create_bin_op(.llvm_udiv, left_val, right_val)
		}
		.less {
			return fd.bld.create_icmp(.int_s_lt, left_val, right_val)
		}
		.greater {
			return fd.bld.create_icmp(.int_s_gt, left_val, right_val)
		}
		.less_or_equals {
			return fd.bld.create_icmp(.int_s_le, left_val, right_val)
		}
		.greater_or_equals {
			return fd.bld.create_icmp(.int_s_ge, left_val, right_val)
		}
		.equals {
			return fd.bld.create_icmp(.int_eq, left_val, right_val)
		}
		.not_equals {
			return fd.bld.create_icmp(.int_ne, left_val, right_val)
		}
		else {
			panic('kind not supported: $binary_expr.op.op_kind')
		}
	}
	panic('kind not supported: $binary_expr.op.op_kind')
}

fn (mut fd FunctionDecl) emit_literal_expr(lit binding.BoundLiteralExpr) core.Value {
	typ := lit.const_val.typ
	match typ.kind {
		.int_symbol {
			return fd.ctx.c_i32(lit.const_val.val as int, true)
		}
		.i64_symbol {
			return fd.ctx.c_i64(u64(lit.const_val.val as i64), true)
		}
		.char_symbol {
			return fd.ctx.c_i8(lit.const_val.val as int, true)
		}
		.byte_symbol {
			return fd.ctx.c_i8(lit.const_val.val as int, false)
		}
		.bool_symbol {
			lit_val := lit.const_val.val as bool
			bool_int := if lit_val { 1 } else { 0 }
			return fd.ctx.c_i1(bool_int, false)
		}
		.string_symbol {
			str_val := lit.const_val.val as string
			return fd.bld.create_global_string_ptr(str_val, '')
		}
		else {
			// not supported yet
			panic('cannot emit literal of type $typ')
		}
	}
	panic('unexpected type $typ')
}

[inline]
fn (mut fd FunctionDecl) dereference_if_ref(expr &binding.BoundExpr, val core.Value) core.Value {
	mut is_ref := expr.typ.is_ref
	if expr is binding.BoundVariableExpr {
		is_ref = expr.var.is_ref
	}
	if is_ref {
		return fd.dereference(val)
	}
	return val
}

[inline]
pub fn (mut fd FunctionDecl) dereference(val core.Value) core.Value {
	typ_kind := val.typ().type_kind()
	if typ_kind != .pointer {
		return val
	}
	elem_typ := val.typ().element_type()
	return fd.bld.create_load2(elem_typ, val)
}
