module core

import lib.comp.binding
import lib.comp.symbols
import lib.comp.token

pub struct Context {
	current_func &C.LLVMValueRef
mut:
	current_block &C.LLVMBasicBlockRef
	mod           Module
	ref_nr        int
	blocks        map[string]&C.LLVMBasicBlockRef
pub mut:
	var_decl      map[string]&C.LLVMValueRef
	last_expr_ref &C.LLVMValueRef
}

pub fn new_context(mod Module, current_block &C.LLVMBasicBlockRef, current_func &C.LLVMValueRef) Context {
	return Context{
		mod: mod
		current_block: current_block
		current_func: current_func
		last_expr_ref: 0
	}
}

fn (mut c Context) new_builtin_call(name string) CallBuilder {
	return new_builtin_call(name, c)
}

fn (mut c Context) emit_call(call_expr binding.BoundCallExpr) &C.LLVMValueRef {
	return emit_call(call_expr, mut c)
}

fn (mut c Context) next_ref_name() string {
	name := '$c.ref_nr'
	c.ref_nr++
	return name
}

fn (mut c Context) emit_expr(node binding.BoundExpr) &C.LLVMValueRef {
	match node {
		binding.BoundLiteralExpr { return c.emit_bound_litera_expr(node) }
		binding.BoundBinaryExpr { return c.emit_binary_expr(node) }
		binding.BoundVariableExpr { return c.emit_variable_expr(node) }
		binding.BoundUnaryExpr { return c.emit_unary_expr(node) }
		binding.BoundCallExpr { return c.emit_call_expr(node) }
		binding.BoundStructInitExpr { return c.emit_struct_init_expr(node) }
		binding.BoundIfExpr { return c.emit_if_expr(node) }
		binding.BoundAssignExpr { return c.emit_assignment_expr(node) }
		else { panic('unexpected expr: $node.kind') }
	}
}

fn (mut c Context) emit_stmt(node binding.BoundStmt) {
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
			c.current_block = c.blocks[node.name]
			C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, c.current_block)
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

fn (mut c Context) emit_cond_goto_stmt(node binding.BoundCondGotoStmt) {
	cond_expr := node.cond_expr
	cond_expr_ref := c.emit_expr(cond_expr)

	eq_block := c.blocks[node.true_label]
	not_eq_block := c.blocks[node.false_label]

	C.LLVMBuildCondBr(c.mod.builder.builder_ref, cond_expr_ref, eq_block, not_eq_block)
}

fn (mut c Context) emit_goto_stmt(node binding.BoundGotoStmt) {
	goto_block := c.blocks[node.label]

	// Check if last instruction is terminator, only
	// if it is not terminated last instruction
	// we add a goto statement
	last_instruction := C.LLVMGetLastInstruction(c.current_block)
	if !isnil(last_instruction) {
		is_term_instr := C.LLVMIsATerminatorInst(last_instruction)
		if isnil(is_term_instr) {
			// No terminator instruction
			// we need to add a branch to next block
			C.LLVMBuildBr(c.mod.builder.builder_ref, goto_block)
		}
	} else {
		// there are no instructions we can add the br
		C.LLVMBuildBr(c.mod.builder.builder_ref, goto_block)
	}
}

fn (mut c Context) emit_assert_stmt(node binding.BoundAssertStmt) {
	//   branch <cond> continue: else assert:
	// assert:
	//   printf <assert inormation>
	//   setjmp() 
	// continue:
	// 	 <rest_of_body> 
	cond_expr := node.expr
	cond_expr_ref := c.emit_expr(cond_expr)

	continue_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.current_func, no_name.str)
	assert_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.current_func, no_name.str)
	C.LLVMMoveBasicBlockAfter(assert_block, c.current_block)
	C.LLVMMoveBasicBlockAfter(continue_block, assert_block)

	C.LLVMBuildCondBr(c.mod.builder.builder_ref, cond_expr_ref, continue_block, assert_block)
	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, assert_block)
	mut cb := c.new_builtin_call('longjmp')
	cb.add_param(c.mod.jmp_buff)
	cb.add_lit_param(i64(1))
	cb.emit()
	C.LLVMBuildUnreachable(c.mod.builder.builder_ref)

	C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, continue_block)
}

fn (mut c Context) emit_if_expr(node binding.BoundIfExpr) &C.LLVMValueRef {
	cond_expr_ref := c.emit_expr(node.cond_expr)

	// Create the temporary variable that will store the result
	// in the then_block and else_block				
	merge_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(node.typ,
		c.mod), no_name.str)
	// C.LLVMBuildStore(c.mod.builder.builder_ref, expr_val_ref, ref_var) 

	then_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.current_func, no_name.str)
	else_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.current_func, no_name.str)
	result_block := C.LLVMAppendBasicBlockInContext(c.mod.ctx_ref, c.current_func, no_name.str)
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

fn (mut c Context) emit_assignment_expr(node binding.BoundAssignExpr) &C.LLVMValueRef {
	expr_ref := c.emit_expr(node.expr)
	var := node.var
	mut ref_var := c.var_decl[var.id]

	typ := var.typ
	if typ is symbols.StructTypeSymbol && node.names.len > 0 {
		ref_var = c.get_reference_to_element(ref_var, typ, node.names)
	}

	C.LLVMBuildStore(c.mod.builder.builder_ref, expr_ref, ref_var)
	return ref_var
}

fn (mut c Context) get_reference_to_element(var_ref &C.LLVMValueRef, struct_symbol symbols.TypeSymbol, names []token.Token) &C.LLVMValueRef {
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

fn (mut c Context) emit_call_expr(node binding.BoundCallExpr) &C.LLVMValueRef {
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

fn (mut c Context) emit_variable_expr(node binding.BoundVariableExpr) &C.LLVMValueRef {
	typ := node.var.typ
	typ_ref := get_llvm_type_ref(typ, c.mod)
	var := c.var_decl[node.var.id] or { panic('unexpected, variable not declared: $node.var.name') }
	mut current_typ_ref := typ_ref
	mut current_typ := typ
	// mut current_val := var
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
			loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, current_typ_ref,
				val, no_name.str)

			return loaded_var
		}
	}

	loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, typ_ref, var, no_name.str)
	return loaded_var
}

fn (mut c Context) emit_var_decl(node binding.BoundVarDeclStmt) {
	typ := node.var.typ
	mut typ_ref := get_llvm_type_ref(typ, c.mod)
	var_name := node.var.name

	expr_val_ref := c.emit_expr(node.expr)

	ref_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, typ_ref, var_name.str)
	C.LLVMBuildStore(c.mod.builder.builder_ref, expr_val_ref, ref_var)
	c.var_decl[node.var.id] = ref_var
}

fn (mut c Context) emit_binary_expr(binary_expr binding.BoundBinaryExpr) &C.LLVMValueRef {
	ref_left := c.emit_expr(binary_expr.left_expr)
	ref_right := c.emit_expr(binary_expr.right_expr)
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

fn (mut c Context) emit_unary_expr(unary_expr binding.BoundUnaryExpr) &C.LLVMValueRef {
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

fn (mut c Context) emit_bound_litera_expr(lit binding.BoundLiteralExpr) &C.LLVMValueRef {
	// id := lit.const_val.id
	typ := lit.const_val.typ
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.name {
				'int' {
					return C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, c.mod),
						lit.const_val.val as int, false)
				}
				'i64' {
					return C.LLVMConstInt(get_llvm_type_ref(symbols.i64_symbol, c.mod),
						lit.const_val.val as i64, false)
				}
				'bool' {
					lit_val := lit.const_val.val as bool
					bool_int := if lit_val { 1 } else { 0 }
					return C.LLVMConstInt(get_llvm_type_ref(symbols.bool_symbol, c.mod),
						bool_int, false)
				}
				'string' {
					str_val := lit.const_val.val as string
					return c.mod.add_global_string_literal_ptr(str_val)
				}
				else {
					// not supported yet
					panic('cannot emit literal of type $typ')
				}
			}
		}
		else {
			panic('unexpected type $typ')
		}
	}
	panic('unexpected type $typ')
}

fn (mut c Context) emit_struct_init_expr(si binding.BoundStructInitExpr) &C.LLVMValueRef {
	// id := lit.const_val.id
	// typ := si.typ as symbols.StructTypeSymbol
	typ_ref := get_llvm_type_ref(si.typ, c.mod)
	mut value_refs := []&C.LLVMValueRef{}
	for member in si.members {
		value_refs << c.emit_expr(member.expr)
	}

	return C.LLVMConstNamedStruct(typ_ref, value_refs.data, value_refs.len)
}

[inline]
fn get_llvm_type_ref(typ symbols.TypeSymbol, mod Module) &C.LLVMTypeRef {
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.name {
				'int' {
					return C.LLVMInt32TypeInContext(mod.ctx_ref)
				}
				'i64' {
					return C.LLVMInt64TypeInContext(mod.ctx_ref)
				}
				'bool' {
					return C.LLVMInt1TypeInContext(mod.ctx_ref)
				}
				'string' {
					return C.LLVMPointerType(C.LLVMInt8TypeInContext(mod.ctx_ref), 0)
				}
				else {
					panic('unexpected, unsupported built-in type: $typ')
				}
			}
		}
		symbols.VoidTypeSymbol {
			return C.LLVMVoidTypeInContext(mod.ctx_ref)
		}
		symbols.StructTypeSymbol {
			return mod.types[typ.id] or { panic('unexpected, type $typ not found in symols table') }
		}
		else {
			panic('unexpected, unsupported type ref $typ')
		}
	}

	panic('unexpected, unsupported type: $typ')
}
