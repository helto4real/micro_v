module core

import lib.comp.binding
import lib.comp.symbols

pub struct Context {
	current_func &C.LLVMValueRef
mut:
	current_block &C.LLVMBasicBlockRef
	mod Module
	ref_nr int
	blocks 	map[string]&C.LLVMBasicBlockRef
pub mut:
	value_refs []&C.LLVMValueRef
	var_decl map[string] &C.LLVMValueRef
}

pub fn new_context(mod Module, current_block &C.LLVMBasicBlockRef, current_func &C.LLVMValueRef) Context {
	return Context{
		mod:mod
		current_block: current_block
		current_func: current_func
	}
}

// pub fn (mut m Module) add_standard_globals() {
// 	glob_nl_fmt_ref := m.add_global_string_literal_ptr('%s\n')
// 	m.global_const['println'] = glob_nl_fmt_ref

// 	glob_fmt_ref := m.add_global_string_literal_ptr('%s')
// 	m.global_const['print'] = glob_fmt_ref
	
// }


fn (mut c Context) next_ref_name() string {
	name := '$c.ref_nr'
	c.ref_nr++
	return name
}
fn (mut c Context) emit_node(node binding.BoundNode) {
	match node {
		binding.BoundExpr {
			if node is binding.BoundLiteralExpr {
				c.emit_bound_litera_expr(node)
			} else if node is binding.BoundBinaryExpr {
				c.emit_binary_expr(node)
			} else if node is binding.BoundVariableExpr {
				c.emit_variable_expr(node)
			} else if node is binding.BoundUnaryExpr {
				c.emit_unary_expr(node)
			} else if node is binding.BoundCallExpr {
				c.emit_call_expr(node)
			} else if node is binding.BoundIfExpr {
				// Evaluate the cond expression
				c.emit_node(node.cond_expr)
				cond_expr_ref := c.value_refs.pop()

				// Create the temporary variable that will store the result
				// in the then_block and else_block				
				merge_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(node.typ, c.mod), no_name.str)
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
				c.emit_node(node.then_stmt)
				then_block_val_ref := c.value_refs.pop()
				C.LLVMBuildStore(c.mod.builder.builder_ref, then_block_val_ref, merge_var) 
				C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

				// handle the logic for then block
				C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, else_block)
				c.current_block = else_block
				c.emit_node(node.else_stmt)
				else_block_val_ref := c.value_refs.pop()
				C.LLVMBuildStore(c.mod.builder.builder_ref, else_block_val_ref, merge_var) 
				C.LLVMBuildBr(c.mod.builder.builder_ref, result_block)

				C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, result_block)
				loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(node.typ, c.mod), merge_var, no_name.str)
				c.value_refs.prepend(loaded_var)
				
				// C.LLVMMoveBasicBlockAfter(then_block, c.current_block)
				// C.LLVMMoveBasicBlockAfter(else_block, then_block)
				
				
				
			} else if  node is binding.BoundAssignExpr {
				c.emit_node(node.expr)
				expr_ref := c.value_refs.pop()
				ref_var := c.var_decl[node.var.id]
				C.LLVMBuildStore(c.mod.builder.builder_ref, expr_ref, ref_var) 
			} else {
				panic('unexpected expr: $node.kind')
			}
		}
		binding.BoundStmt {
			if node is binding.BoundReturnStmt {
				if node.has_expr {
					c.emit_node(node.expr)
					ref := c.value_refs.pop()
					C.LLVMBuildRet(c.mod.builder.builder_ref, ref)
				} else {
					C.LLVMBuildRetVoid(c.mod.builder.builder_ref)
				}
				
			} else if node is binding.BoundVarDeclStmt {
				c.emit_var_decl(node)
			} else if node is binding.BoundExprStmt {
				c.emit_node(node.bound_expr)
			} else if node is binding.BoundLabelStmt {
				// is_term_instruction := C.LLVMIsATerminatorInst(last_instruction)
				// if C.LLVMIsNull(is_term_instruction) == 0 {
				// 	print('IS TERM: ')
				// 	C.LLVMDumpValue(is_term_instruction)
				// 	println('')
				// }
				c.current_block = c.blocks[node.name]
				C.LLVMPositionBuilderAtEnd(c.mod.builder.builder_ref, c.current_block)
			} else if node is binding.BoundCondGotoStmt {
				cond_expr := node.cond
				c.emit_node(cond_expr)
				cond_expr_ref := c.value_refs.pop()
				
				eq_block := c.blocks[node.true_label]
				not_eq_block := c.blocks[node.false_label]

				C.LLVMBuildCondBr(c.mod.builder.builder_ref, cond_expr_ref, eq_block, not_eq_block)

			} else if node is binding.BoundCommentStmt {
			
			} else if node is binding.BoundGotoStmt {
				goto_block := c.blocks[node.label]

				// Check if last instruction is terminator, only
				// if it is not terminated last instruction
				// we add a goto statement
				last_instruction := C.LLVMGetLastInstruction(c.current_block)
				if !isnil(last_instruction)  {
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
			} else if node is binding.BoundBlockStmt {
				for stmt in node.bound_stmts {
					c.emit_node(stmt)
				}

			}  else {
				panic('unexepected unsupported statement $node.kind')
			}

		}
	}
}

fn (mut c Context) emit_call_expr(node binding.BoundCallExpr) {
	// TODO: #11 refator when built-in functions are growing in numbers
	if node.func.name in ['println', 'print'] {
		glob_str_println := c.mod.global_const[GlobalVarRefType.printf_str_nl] or {
			println_str := c.mod.add_global_string_literal_ptr('%s\n')
			c.mod.global_const[GlobalVarRefType.printf_str_nl]  = println_str
			println_str
		}
		glob_str_print := c.mod.global_const[GlobalVarRefType.printf_str] or {
			print_str := c.mod.add_global_string_literal_ptr('%s')
			c.mod.global_const[GlobalVarRefType.printf_str]  = print_str
			print_str
		}

		c.emit_node(node.params[0])
		fn_ref := c.mod.built_in_funcs['printf'] or {panic('built in function println not found')}
		mut params := []&C.LLVMValueRef{cap: 1}
		param := c.value_refs.pop()
		glob_print_str := if node.func.name == 'print' {glob_str_print} else {glob_str_println}
		params << glob_print_str
		params << param

		C.LLVMBuildCall(c.mod.builder.builder_ref, fn_ref,
                            params.data, 2,
                            no_name.str) 

	} else {
		// handle the parameters 
		mut params := []&C.LLVMValueRef{}
		for param in node.params {
			c.emit_node(param)
			param_ref := c.value_refs.pop()
			println('Paramref: $param_ref')
			params << param_ref
		}
		fun := c.mod.funcs[node.func.id] or { panic('unexpected, $node.func.name ($node.func.id) func not declared')}
		fn_ref := fun.llvm_func
		C.LLVMBuildCall(c.mod.builder.builder_ref, fn_ref,
                            params.data, params.len,
                            no_name.str) 

	}
}
fn (mut c Context) emit_variable_expr(node binding.BoundVariableExpr) {
	typ := node.var.typ
	var := c.var_decl[node.var.id] or {panic('unexpected, variable not declared: $node.var.name')}
	loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ, c.mod), var, no_name.str)
	c.value_refs.prepend(loaded_var)
}
fn (mut c Context) emit_var_decl(node binding.BoundVarDeclStmt) {
	typ := node.var.typ
	var_name := node.var.name

	c.emit_node(node.expr)
	expr_val_ref := c.value_refs.pop()

	ref_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(typ, c.mod), var_name.str)
	// ref2 := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ), expr_val_ref, no_name.str)
	C.LLVMBuildStore(c.mod.builder.builder_ref, expr_val_ref, ref_var) 
	c.var_decl[node.var.id] = ref_var
}

fn (mut c Context) emit_binary_expr(binary_expr binding.BoundBinaryExpr) {
	// Handle left side
	// typ := binary_expr.typ
	c.emit_node(binary_expr.left)
	ref_left := c.value_refs.pop()
	c.emit_node(binary_expr.right)
	ref_right := c.value_refs.pop()
	match binary_expr.op.op_kind {
		.addition {
			add_ref := C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_add, ref_left, ref_right,
                            no_name.str)
			c.value_refs.prepend(add_ref)
		}
		.subraction {
			sub_ref := C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_sub, ref_left, ref_right,
                            no_name.str)
			c.value_refs.prepend(sub_ref)
		}
		.multiplication {
			mul_ref := C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_mul, ref_left, ref_right,
                            no_name.str)
			c.value_refs.prepend(mul_ref)
		}
		.divition {
			div_ref := C.LLVMBuildBinOp(c.mod.builder.builder_ref, .llvm_udiv, ref_left, ref_right,
                            no_name.str)
			c.value_refs.prepend(div_ref)
		}
		.less {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_lt, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)
		}
		.greater {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_gt, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)
		}
		.less_or_equals {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_le, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)
		}
		.greater_or_equals {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_s_ge, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)

		}
		.equals {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_eq, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)

		}
		.not_equals {
			cmp_ref := C.LLVMBuildICmp(c.mod.builder.builder_ref, .int_ne, ref_left, ref_right, no_name.str)
			c.value_refs.prepend(cmp_ref)
		}
		else {panic('kind not supported: $binary_expr.op.op_kind')}
	}
}
fn (mut c Context) emit_unary_expr(unary_expr binding.BoundUnaryExpr) {
	c.emit_node(unary_expr.operand)
	typ := unary_expr.typ
	match unary_expr.op.op_kind {
		.negation {
			ref := c.value_refs.pop()
			ref2 := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ, c.mod), ref, no_name.str)
			val_ref := C.LLVMBuildNeg(c.mod.builder.builder_ref, ref2, no_name.str)
			c.value_refs.prepend(val_ref)
		} else {
			panic('unary operation $unary_expr is not supported')
		}
	}
}
fn (mut c Context) emit_bound_litera_expr(lit binding.BoundLiteralExpr) {
	// id := lit.const_val.id
	typ := lit.const_val.typ
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.name {
				'int' {
					val := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol, c.mod), lit.const_val.val as int, false)
					c.value_refs.prepend(val)
				}
				'bool' {
					lit_val := lit.const_val.val as bool
					bool_int := if lit_val {1} else {0}
					val := C.LLVMConstInt(get_llvm_type_ref(symbols.bool_symbol, c.mod), bool_int, false)
					c.value_refs.prepend(val)
				}
				'string' {
					str_val :=  lit.const_val.val as string
					ptr := c.mod.add_global_string_literal_ptr(str_val)
					
					c.value_refs.prepend(ptr)
				}
				else {
					// not supported yet
					panic('Cannot emit literal of type $typ')
				}
			}
		}
		else {
			// TODO: add structs
		}
	}
}



[inline]
fn get_llvm_type_ref(typ symbols.TypeSymbol, mod Module) &C.LLVMTypeRef {
	match typ {
		symbols.BuiltInTypeSymbol {
			match typ.name {
				'int' {
					return C.LLVMInt32TypeInContext(mod.ctx_ref)
				}
				'bool' {
					return C.LLVMInt1TypeInContext(mod.ctx_ref)
				}
				'string' {
					return C.LLVMPointerType(C.LLVMInt8TypeInContext(mod.ctx_ref), 0)
				}
				else {panic('unexpected, unsupported built-in type: $typ')}
			}
		}
		symbols.VoidTypeSymbol {
			return C.LLVMVoidTypeInContext(mod.ctx_ref)
		}
		else {
			// TODO: Add struct support
		}
	}

	panic('unexpected, unsupported type: $typ')
}