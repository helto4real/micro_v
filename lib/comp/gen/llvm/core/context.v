module core

import lib.comp.binding
import lib.comp.symbols
import lib.comp.token
import lib.comp.util.source

pub struct Emitter {
mut:
	func          &Function
	current_block &C.LLVMBasicBlockRef
	mod           &Module
	ref_nr        int
	blocks        map[string]&C.LLVMBasicBlockRef
pub mut:
	last_expr_ref &C.LLVMValueRef
}

pub fn new_emitter(mod &Module, current_block &C.LLVMBasicBlockRef, func &Function) &Emitter {
	return &Emitter{
		mod: mod
		current_block: current_block
		func: func
		last_expr_ref: 0
	}
}

fn (mut c Emitter) new_builtin_call(name string) CallBuilder {
	return new_builtin_call(name, c)
}

fn (mut c Emitter) handle_box_unbox_variable(var &symbols.VariableSymbol, expr &binding.BoundExpr, val &C.LLVMValueRef) &C.LLVMValueRef {
	is_const := C.LLVMIsConstant(val) == 1

	if var.is_ref && (is_const || !expr.typ.is_ref) {
		var_typ_ref := get_llvm_type_ref(var.typ, c.mod)
		res_val := C.LLVMBuildAlloca(c.mod.builder.builder_ref, var_typ_ref, no_name.str)
		C.LLVMBuildStore(c.mod.builder.builder_ref, val, res_val)
		return res_val
	}
	if !var.is_ref && expr.typ.is_ref {
		return C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(var.typ,
			c.mod), val, no_name.str)
	}
	return val
}

fn (mut c Emitter) emit_call(call_expr binding.BoundCallExpr) &C.LLVMValueRef {
	func_res := c.mod.funcs.filter(it.func.id == call_expr.func.id)
	if func_res.len != 1 {
		panic('unexpected, $call_expr.func.name ($call_expr.func.id) func not declared. ')
	}

	func := func_res[0]
	params_len := if func.func.receiver.is_empty {
		call_expr.params.len
	} else {
		call_expr.params.len + 1
	}
	mut params := []&C.LLVMValueRef{cap: params_len}
	if !func.func.receiver.is_empty {
		receiver_decl_ref := c.func.var_decl[call_expr.receiver.id] or {
			panic('receiver: $call_expr.receiver ($call_expr.receiver.id) is not declared')
		}
		if !func.func.receiver.is_ref {
			unboxed_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(func.func.receiver.typ,
				c.mod), receiver_decl_ref, no_name.str)
			params << unboxed_var
		} else {
			params << receiver_decl_ref // c.handle_box_unbox_variable(func.func.receiver, receiver_decl_ref)
		}
	}
	for i, param_expr in call_expr.params {
		expr := c.emit_expr(param_expr)
		decl_param := func.func.params[i]

		// if param.typ.is_ref {
		// 	params << expr
		// } else {
		params << c.handle_box_unbox_variable(&decl_param, &param_expr, expr)
		// }
	}

	mut call_builder := CallBuilder{
		name: func.func.name
		ctx: c
		func: func
		params: params
		fn_ref: func.func_ref
		is_built_in: false
	}

	if call_expr.typ.kind == symbols.TypeSymbolKind.void_symbol {
		// no return value
		call_builder.emit()
		return 0
	}

	return call_builder.emit()
}

fn (mut c Emitter) emit_expr(node binding.BoundExpr) &C.LLVMValueRef {
	match node {
		binding.BoundConvExpr { return c.emit_convert_expr(node) }
		binding.BoundLiteralExpr { return c.emit_literal_expr(node) }
		binding.BoundBinaryExpr { return c.emit_binary_expr(node) }
		binding.BoundVariableExpr { return c.emit_variable_expr(node) }
		binding.BoundUnaryExpr { return c.emit_unary_expr(node) }
		binding.BoundCallExpr { return c.emit_call_expr(node) }
		binding.BoundStructInitExpr { return c.emit_struct_init_expr(node) }
		binding.BoundArrayInitExpr { return c.emit_array_init_expr(node) }
		binding.BoundIndexExpr { return c.emit_array_index_expr(node) }
		binding.BoundIfExpr { return c.emit_if_expr(node) }
		binding.BoundAssignExpr { return c.emit_assignment_expr(node) }
		else { panic('unexpected expr: $node.kind') }
	}
}

fn (mut c Emitter) emit_stmt(node binding.BoundStmt) {
	// kind_str:='$node.kind'
	// met := C.LLVMGetOrInsertNamedMetadata(c.mod.mod_ref, kind_str.str, kind_str.len)
	match node {
		binding.BoundReturnStmt {
			if node.has_expr {
				ref := c.emit_expr(node.expr)
				C.LLVMBuildRet(c.mod.builder.builder_ref, ref)
			} else {
				C.LLVMBuildRetVoid(c.mod.builder.builder_ref)
			}
		}
		binding.BoundVarDeclStmt {
			c.emit_var_decl(node)
		}
		binding.BoundAssertStmt {
			c.emit_assert_stmt(node)
		}
		binding.BoundExprStmt {
			c.last_expr_ref = c.emit_expr(node.expr)
		}
		binding.BoundLabelStmt {
			c.emit_label_stmt(node)
		}
		binding.BoundCondGotoStmt {
			c.emit_cond_goto_stmt(node)
		}
		binding.BoundCommentStmt {} // Ignore comments
		binding.BoundGotoStmt {
			c.emit_goto_stmt(node)
		}
		binding.BoundBlockStmt {
			for stmt in node.stmts {
				c.emit_stmt(stmt)
			}
		}
		else {
			panic('unexepected unsupported statement $node.kind')
		}
	}
}

fn (mut c Emitter) emit_cond_goto_stmt(node binding.BoundCondGotoStmt) {
	cond_expr := node.cond_expr
	cond_expr_ref := c.emit_expr(cond_expr)

	eq_block := c.blocks[node.true_label]
	not_eq_block := c.blocks[node.false_label]

	C.LLVMBuildCondBr(c.mod.builder.builder_ref, cond_expr_ref, eq_block, not_eq_block)
}

fn (mut c Emitter) emit_label_stmt(node binding.BoundLabelStmt) {
	label_block := c.blocks[node.name]

	// Check if last instruction is terminator, only
	// if it is not terminated last instruction
	// we add a goto statement
	last_instruction := C.LLVMGetLastInstruction(c.current_block)
	if !isnil(last_instruction) {
		is_term_instr := C.LLVMIsATerminatorInst(last_instruction)
		if isnil(is_term_instr) {
			// No terminator instruction
			// we need to add a branch to next block
			C.LLVMBuildBr(c.mod.builder.builder_ref, label_block)
		}
	} else {
		// there are no instructions we can add the br
		C.LLVMBuildBr(c.mod.builder.builder_ref, label_block)
	}
	c.current_block = label_block
	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, c.current_block)
}

fn (mut c Emitter) emit_goto_stmt(node binding.BoundGotoStmt) {
	goto_block := c.blocks[node.label]
	C.LLVMBuildBr(c.mod.builder.builder_ref, goto_block)
}

[inline]
fn (mut c Emitter) unbox_if_ref(typ &symbols.TypeSymbol, val_ref &C.LLVMValueRef) &C.LLVMValueRef {
	if typ.is_ref {
		return C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ, c.mod),
			val_ref, no_name.str)
	}
	return val_ref
}

fn (mut c Emitter) emit_assert_stmt(node binding.BoundAssertStmt) {
	//   branch <cond> continue: else assert:
	// assert:
	//   printf <assert inormation>
	//   setjmp()
	// continue:
	// 	 <rest_of_body>
	cond_expr := node.expr
	// mut cont_expr_ref := c.emit_expr(cond_expr)

	// // typ_ref := C.LLVMTypeOf(cont_expr_ref)
	// println('cond_expr: $cond_expr : $node.expr.typ.is_ref')
	// C.LLVMDumpType(typ_ref)
	// println('')
	cont_expr_ref := c.unbox_if_ref(&node.expr.typ, c.emit_expr(cond_expr))
	// typ_ref2 :=  C.LLVMTypeOf(cont_expr_ref)

	assert_cont_name := 'assert_cont'
	assert_name := 'assert'
	continue_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.func.func_ref,
		assert_cont_name.str)
	assert_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.func.func_ref, assert_name.str)
	C.LLVMMoveBasicBlockAfter(assert_block, c.current_block)
	C.LLVMMoveBasicBlockAfter(continue_block, assert_block)

	C.LLVMBuildCondBr(c.mod.builder.builder_ref, cont_expr_ref, continue_block, assert_block)
	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, assert_block)
	// insert to print assert information

	mut sw := source.SourceWriter{}
	source.write_diagnostic(mut sw, node.location, 'assert error', 1)
	c.println(sw.str())

	// then do longjmp to exit
	mut cb := c.new_builtin_call('longjmp')
	cb.add_param(c.mod.jmp_buff)
	cb.add_lit_param(i64(1))
	cb.emit()
	C.LLVMBuildUnreachable(c.mod.builder.builder_ref)

	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, continue_block)
}

// TODO: refactor this into several smaller functions
fn (mut c Emitter) emit_convert_expr(node binding.BoundConvExpr) &C.LLVMValueRef {
	expr := node.expr
	expr_val_ref := c.emit_expr(expr)
	from_typ := expr.typ
	to_typ := node.typ
	match from_typ {
		symbols.BuiltInTypeSymbol {
			match from_typ.kind {
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
				.int_symbol {
					match to_typ.kind {
						.string_symbol {
							glob_num_println := c.mod.global_const[GlobalVarRefType.printf_num] or {
								number_str := c.mod.add_global_string_literal_ptr('%d')
								c.mod.global_const[GlobalVarRefType.printf_num] = number_str
								number_str
							}
							cast := C.LLVMBuildPointerCast(c.mod.builder.builder_ref,
								c.mod.global_const[GlobalVarRefType.sprintf_buff], C.LLVMPointerType(C.LLVMInt8TypeInContext(c.mod.ctx_ref),
								0), no_name.str)
							mut cb := c.new_builtin_call('sprintf')
							cb.add_param(cast)
							cb.add_param(glob_num_println)
							cb.add_param(expr_val_ref)
							cb.emit()
							return cast
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
							glob_str_true := c.mod.global_const[GlobalVarRefType.str_true] or {
								print_str := c.mod.add_global_string_literal_ptr('true')
								c.mod.global_const[GlobalVarRefType.str_true] = print_str
								print_str
							}
							glob_str_false := c.mod.global_const[GlobalVarRefType.str_false] or {
								print_str := c.mod.add_global_string_literal_ptr('false')
								c.mod.global_const[GlobalVarRefType.str_false] = print_str
								print_str
							}

							res_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(to_typ,
								c.mod), no_name.str)

							true_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref,
								c.func.func_ref, no_name.str)
							false_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref,
								c.func.func_ref, no_name.str)
							result_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref,
								c.func.func_ref, no_name.str)
							C.LLVMMoveBasicBlockAfter(true_block, c.current_block)
							C.LLVMMoveBasicBlockAfter(false_block, true_block)

							C.LLVMBuildCondBr(c.mod.builder.builder_ref, expr_val_ref,
								true_block, false_block)

							// handle the logic for then block
							C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, true_block)
							c.current_block = true_block
							C.LLVMBuildStore(c.mod.builder.builder_ref, glob_str_true,
								res_var)
							C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

							// handle the logic for then block
							C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, false_block)
							c.current_block = false_block
							C.LLVMBuildStore(c.mod.builder.builder_ref, glob_str_false,
								res_var)
							C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

							C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, result_block)
							return C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(to_typ,
								c.mod), res_var, no_name.str)
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
		else {
			panic('from type $from_typ conversion not supported yet')
		}
	}
	panic('from type $from_typ conversion not supported yet')
}

fn (mut c Emitter) emit_if_expr(node binding.BoundIfExpr) &C.LLVMValueRef {
	cond_expr_ref := c.emit_expr(node.cond_expr)

	// Create the temporary variable that will store the result
	// in the then_block and else_block				
	merge_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(node.typ,
		c.mod), no_name.str)
	// C.LLVMBuildStore(c.mod.builder.builder_ref, expr_val_ref, ref_var)

	then_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.func.func_ref, no_name.str)
	else_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.func.func_ref, no_name.str)
	result_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.func.func_ref, no_name.str)
	C.LLVMMoveBasicBlockAfter(then_block, c.current_block)
	C.LLVMMoveBasicBlockAfter(else_block, then_block)

	C.LLVMBuildCondBr(c.mod.builder.builder_ref, cond_expr_ref, then_block, else_block)

	// handle the logic for then block
	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, then_block)
	c.current_block = then_block
	c.emit_stmt(node.then_stmt)
	then_block_val_ref := c.last_expr_ref
	C.LLVMBuildStore(c.mod.builder.builder_ref, then_block_val_ref, merge_var)
	C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

	// handle the logic for then block
	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, else_block)
	c.current_block = else_block
	c.emit_stmt(node.else_stmt)
	else_block_val_ref := c.last_expr_ref
	C.LLVMBuildStore(c.mod.builder.builder_ref, else_block_val_ref, merge_var)
	C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, result_block)
	return C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(node.typ, c.mod),
		merge_var, no_name.str)
}

fn (mut c Emitter) emit_array_index_expr(node binding.BoundIndexExpr) &C.LLVMValueRef {
	var_ref := c.emit_expr(node.left_expr)
	index_ref := c.emit_expr(node.index_expr)
	arr_typ := node.left_expr.typ as symbols.ArrayTypeSymbol
	typ_ref := get_llvm_type_ref(arr_typ, c.mod)
	elem_typ_ref := get_llvm_type_ref(arr_typ.elem_typ, c.mod)
	mut indicies := [C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), 0, false),
		index_ref,
	]

	gep_val_ref := C.LLVMBuildInBoundsGEP2(c.mod.builder.builder_ref, typ_ref, var_ref,
		indicies.data, indicies.len, no_name.str)
	return C.LLVMBuildLoad2(c.mod.builder.builder_ref, elem_typ_ref, gep_val_ref, no_name.str)
}

fn (mut c Emitter) emit_assignment_expr(node binding.BoundAssignExpr) &C.LLVMValueRef {
	expr_ref := c.emit_expr(node.expr)
	var := node.var
	mut ref_var := c.func.var_decl[var.id]

	typ := var.typ
	if typ is symbols.StructTypeSymbol && node.names.len > 0 {
		ref_var = c.get_reference_to_element(ref_var, typ, node.names)
	}
	C.LLVMBuildStore(c.mod.builder.builder_ref, expr_ref, ref_var)
	return ref_var
}

fn (mut c Emitter) get_reference_to_element(var_ref &C.LLVMValueRef, struct_symbol symbols.TypeSymbol, names []token.Token) &C.LLVMValueRef {
	typ_ref := get_llvm_type_ref(struct_symbol, c.mod)

	// mut current_typ_ref := typ_ref
	mut current_typ := struct_symbol
	mut indicies := [C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), 0, false)]

	for i, name in names {
		if i == 0 {
			continue
		}

		idx := current_typ.lookup_member_index(name.lit)
		current_typ = current_typ.lookup_member_type(name.lit)
		// current_typ_ref = get_llvm_type_ref(current_typ, c.mod)
		if idx < 0 {
			panic('unexepected, lookup member $name, resultet in error')
		}
		indicies << C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), idx, false)
	}

	return C.LLVMBuildInBoundsGEP2(c.mod.builder.builder_ref, typ_ref, var_ref, indicies.data,
		indicies.len, no_name.str)
	// loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, current_typ_ref,
	// 				val, no_name.str)
}

fn (mut c Emitter) emit_call_expr(node binding.BoundCallExpr) &C.LLVMValueRef {
	// TODO: #11 refator when built-in functions are growing in numbers
	if node.func.name in ['println', 'print'] {
		glob_str_println := c.mod.global_const[GlobalVarRefType.printf_str_nl] or {
			println_str := c.mod.add_global_string_literal_ptr('%s\n')
			c.mod.global_const[GlobalVarRefType.printf_str_nl] = println_str
			println_str
		}
		glob_str_print := c.mod.global_const[GlobalVarRefType.printf_str] or {
			print_str := c.mod.add_global_string_literal_ptr('%s')
			c.mod.global_const[GlobalVarRefType.printf_str] = print_str
			print_str
		}
		glob_print_str := if node.func.name == 'print' { glob_str_print } else { glob_str_println }

		param := c.emit_expr(node.params[0])

		mut builder := c.new_builtin_call('printf')
		builder.add_param(glob_print_str)
		builder.add_param(param)
		builder.emit()
	} else if node.func.name == 'exit' {
		param := c.emit_expr(node.params[0])
		mut builder := c.new_builtin_call('exit')
		builder.add_param(param)
		builder.emit()
	} else {
		res := c.emit_call(node)
		return res
	}
	return 0
}

fn (mut c Emitter) emit_variable_expr(node binding.BoundVariableExpr) &C.LLVMValueRef {
	typ := node.var.typ
	typ_ref := get_llvm_type_ref(typ, c.mod)
	var := c.func.var_decl[node.var.id] or {
		panic('unexpected, variable not declared: $node.var.name')
	}
	mut current_typ_ref := typ_ref
	mut current_typ := typ

	if typ is symbols.StructTypeSymbol {
		if node.names.len > 0 {
			mut indicies := [C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), 0,
				false)]

			for i, name in node.names {
				if i == 0 {
					continue
				}
				idx := current_typ.lookup_member_index(name.lit)
				current_typ = current_typ.lookup_member_type(name.lit)
				current_typ_ref = get_llvm_type_ref(current_typ, c.mod)
				if idx < 0 {
					panic('unexepected, lookup member $name, resultet in error')
				}
				indicies << C.LLVMConstInt(C.LLVMInt32TypeInContext(c.mod.ctx_ref), idx,
					false)
			}

			val := C.LLVMBuildInBoundsGEP2(c.mod.builder.builder_ref, typ_ref, var, indicies.data,
				indicies.len, no_name.str)

			if current_typ.is_ref {
				return var
			}

			loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, current_typ_ref,
				val, no_name.str)

			return loaded_var
		}
	}
	if node.typ.is_ref || node.typ.kind == .array_symbol {
		return var
	}

	loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, typ_ref, var, no_name.str)
	return loaded_var
}

fn (mut c Emitter) emit_var_decl(node binding.BoundVarDeclStmt) {
	typ := node.var.typ
	mut typ_ref := get_llvm_type_ref(typ, c.mod)
	var_name := node.var.name

	expr_val_ref := c.emit_expr(node.expr)
	// Todo: only do this is not a reference
	ref_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, typ_ref, var_name.str)
	C.LLVMBuildStore(c.mod.builder.builder_ref, expr_val_ref, ref_var)
	c.func.var_decl[node.var.id] = ref_var
}

fn (mut c Emitter) emit_binary_expr(binary_expr binding.BoundBinaryExpr) &C.LLVMValueRef {
	ref_left := c.unbox_if_ref(&binary_expr.left_expr.typ, c.emit_expr(binary_expr.left_expr))
	ref_right := c.unbox_if_ref(&binary_expr.right_expr.typ, c.emit_expr(binary_expr.right_expr))
	match binary_expr.op.op_kind {
		.addition {
			return C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_add, ref_left, ref_right,
				no_name.str)
		}
		.subraction {
			return C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_sub, ref_left, ref_right,
				no_name.str)
		}
		.multiplication {
			return C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_mul, ref_left, ref_right,
				no_name.str)
		}
		.divition {
			return C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_udiv, ref_left, ref_right,
				no_name.str)
		}
		.less {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_lt, ref_left, ref_right,
				no_name.str)
		}
		.greater {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_gt, ref_left, ref_right,
				no_name.str)
		}
		.less_or_equals {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_le, ref_left, ref_right,
				no_name.str)
		}
		.greater_or_equals {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_ge, ref_left, ref_right,
				no_name.str)
		}
		.equals {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_eq, ref_left, ref_right,
				no_name.str)
		}
		.not_equals {
			return C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_ne, ref_left, ref_right,
				no_name.str)
		}
		else {
			panic('kind not supported: $binary_expr.op.op_kind')
		}
	}
	panic('kind not supported: $binary_expr.op.op_kind')
}

fn (mut c Emitter) emit_unary_expr(unary_expr binding.BoundUnaryExpr) &C.LLVMValueRef {
	operand_expr_val_ref := c.emit_expr(unary_expr.operand_expr)
	// typ := unary_expr.typ
	match unary_expr.op.op_kind {
		.negation {
			return C.LLVMBuildNeg(c.mod.builder.builder_ref, operand_expr_val_ref, no_name.str)
		}
		.logic_negation {
			return C.LLVMBuildNot(c.mod.builder.builder_ref, operand_expr_val_ref, no_name.str)
		}
		else {
			panic('unary operation $unary_expr ($unary_expr.op.op_kind) not supported')
		}
	}
}

fn (mut c Emitter) emit_literal_expr(lit binding.BoundLiteralExpr) &C.LLVMValueRef {
	// id := lit.const_val.id
	typ := lit.const_val.typ
	match typ.kind {
		.int_symbol {
			return C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, c.mod), lit.const_val.val as int,
				false)
		}
		.i64_symbol {
			return C.LLVMConstInt(get_llvm_type_ref(symbols.i64_symbol, c.mod), lit.const_val.val as i64,
				false)
		}
		.bool_symbol {
			lit_val := lit.const_val.val as bool
			bool_int := if lit_val { 1 } else { 0 }
			return C.LLVMConstInt(get_llvm_type_ref(symbols.bool_symbol, c.mod), bool_int,
				false)
		}
		.string_symbol {
			str_val := lit.const_val.val as string
			return c.mod.add_global_string_literal_ptr(str_val)
		}
		else {
			// not supported yet
			panic('cannot emit literal of type $typ')
		}
	}
	panic('unexpected type $typ')
}

fn (mut c Emitter) emit_array_init_expr(ai binding.BoundArrayInitExpr) &C.LLVMValueRef {
	arr_typ := ai.typ as symbols.ArrayTypeSymbol
	typ_ref := get_llvm_type_ref(arr_typ.elem_typ, c.mod)
	mut value_refs := []&C.LLVMValueRef{}
	for expr in ai.exprs {
		value_refs << c.emit_expr(expr)
	}
	return C.LLVMConstArray(typ_ref, value_refs.data, value_refs.len)
}

fn (mut c Emitter) emit_struct_init_expr(si binding.BoundStructInitExpr) &C.LLVMValueRef {
	// id := lit.const_val.id
	// typ := si.typ as symbols.StructTypeSymbol
	typ_ref := get_llvm_type_ref(si.typ, c.mod)
	mut value_refs := []&C.LLVMValueRef{}
	for member in si.members {
		value_refs << c.emit_expr(member.expr)
	}

	return C.LLVMConstNamedStruct(typ_ref, value_refs.data, value_refs.len)
}

fn (mut c Emitter) println(text string) {
	lit_expr := binding.new_bound_literal_expr(text) as binding.BoundLiteralExpr
	lit_expr_ref := c.emit_literal_expr(lit_expr)
	glob_str_println := c.get_global_string(.printf_str_nl)

	mut builder := c.new_builtin_call('printf')
	if text.len > 0 {
		builder.add_param(glob_str_println)
		builder.add_param(lit_expr_ref)
	} else {
		// empty string
		builder.add_param(c.get_global_string(.nl))
	}
	builder.emit()
}

fn (mut c Emitter) get_global_string(ref_typ GlobalVarRefType) &C.LLVMValueRef {
	match ref_typ {
		.printf_str {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('%s')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		.printf_str_nl {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('%s\n')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		.printf_num {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('%d')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		.str_true {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('true')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		.str_false {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('false')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		.nl {
			return c.mod.global_const[ref_typ] or {
				str_ref := c.mod.add_global_string_literal_ptr('\n')
				c.mod.global_const[ref_typ] = str_ref
				str_ref
			}
		}
		else {}
	}
	panic('unexepected, missing handle of global string')
}

[inline]
fn get_llvm_type_ref(typ symbols.TypeSymbol, mod Module) &C.LLVMTypeRef {
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.kind {
				.int_symbol {
					return C.LLVMInt32TypeInContext(mod.ctx_ref)
				}
				.i64_symbol {
					return C.LLVMInt64TypeInContext(mod.ctx_ref)
				}
				.bool_symbol {
					return C.LLVMInt1TypeInContext(mod.ctx_ref)
				}
				.string_symbol {
					return C.LLVMPointerType(C.LLVMInt8TypeInContext(mod.ctx_ref), 0)
				}
				.byte_symbol {
					return C.LLVMInt8TypeInContext(mod.ctx_ref)
				}
				.char_symbol {
					return C.LLVMInt8TypeInContext(mod.ctx_ref)
				}
				else {
					panic('unexpected, unsupported built-in type: $typ')
				}
			}
		}
		symbols.ArrayTypeSymbol {
			elem_typ_ref := get_llvm_type_ref(typ.elem_typ, mod)
			return C.LLVMArrayType(elem_typ_ref, typ.len)
		}
		symbols.VoidTypeSymbol {
			return C.LLVMVoidTypeInContext(mod.ctx_ref)
		}
		symbols.StructTypeSymbol {
			return mod.types[typ.id] or { panic('unexpected, type $typ not found in symols table') }
		}
		else {
			panic('unexpected, unsupported type ref $typ, $typ.kind')
		}
	}

	panic('unexpected, unsupported type: $typ')
}
