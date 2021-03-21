module core

import lib.comp.binding
import lib.comp.symbols
const (
	no_name = '\00'
)
pub struct Context {
	mod Module
	current_block C.LLVMBasicBlockRef
mut:
	ref_nr int
pub mut:
	value_refs []C.LLVMValueRef
	var_decl map[string] C.LLVMValueRef
}

pub fn new_context(mod Module, current_block C.LLVMBasicBlockRef) Context {
	return Context{
		mod:mod
		current_block: current_block
	}
}

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
			} else {
				
			}
		}
		binding.BoundStmt {
			if node is binding.BoundReturnStmt {
				c.emit_node(node.expr)
				ref := c.value_refs.pop()
				
				C.LLVMBuildRet(c.mod.builder.builder_ref, ref)
			} else if node is binding.BoundVarDeclStmt {
				c.emit_var_decl(node)
			} else if node is binding.BoundExprStmt {
				c.emit_node(node.bound_expr)
			}
			// if node is binding.BoundLabelStmt {
			// 	b.writeln(term.bright_cyan(' $node.name'))
			// } else if node is binding.BoundCondGotoStmt {
			// 	b.writeln(term.bright_cyan(' $node.jump_if_true -> $node.label'))
			// } else if node is binding.BoundGotoStmt {
			// 	b.writeln(term.bright_cyan(' $node.label'))
			// } else if node is binding.BoundForStmt {
			// 	b.writeln(term.bright_cyan(' $node.child_nodes.len'))

			// } else {
			// 	b.writeln('')
			// }
		}
	}
}

fn (mut c Context) emit_call_expr(node binding.BoundCallExpr) {
	if node.func.name in ['println', 'print'] {
		c.emit_node(node.params[0])
		fn_ref := c.mod.built_in_funcs['printf'] or {panic('built in function println not found')}
		// fn_ref := c.mod.built_in_funcs['puts'] or {panic('built in function println not found')}
		mut params := []C.LLVMValueRef{cap: 1}
		param := c.value_refs.pop()
		fmt_str := if node.func.name == 'print' {'%s'} else {'%s\n'}
		params << c.add_global_string_literal_ptr(fmt_str)
		params << param

		// C.LLVMDumpValue(fn_ref)
		// C.LLVMDumpValue(param)
		// C.LLVMDumpModule(c.mod.mod_ref)

		C.LLVMBuildCall(c.mod.builder.builder_ref, fn_ref,
                            params.data, 2,
                            no_name.str) 

	}
}
fn (mut c Context) emit_variable_expr(node binding.BoundVariableExpr) {
	typ := node.var.typ
	var := c.var_decl[node.var.id] or {panic('unexpected, variable not declared')}
	loaded_var := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ), var, no_name.str)
	c.value_refs.prepend(loaded_var)
}
fn (mut c Context) emit_var_decl(node binding.BoundVarDeclStmt) {
	typ := node.var.typ
	var_name := node.var.name

	c.emit_node(node.expr)
	expr_val_ref := c.value_refs.pop()

	ref_var := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(typ), var_name.str)
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
	// load_left := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ), ref_left, no_name.str)
	// load_right := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ), ref_right, no_name.str)
	match binary_expr.op.op_kind {
		.addition {
			println('ADD')
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
		else {}
	}
}
fn (mut c Context) emit_unary_expr(unary_expr binding.BoundUnaryExpr) {
	c.emit_node(unary_expr.operand)
	typ := unary_expr.typ
	match unary_expr.op.op_kind {
		.negation {
			ref := c.value_refs.pop()
			ref2 := C.LLVMBuildLoad2(c.mod.builder.builder_ref, get_llvm_type_ref(typ), ref, no_name.str)
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
	match typ.name {
		'int' {
			// ref := C.LLVMBuildAlloca(c.mod.builder.builder_ref, get_llvm_type_ref(typ), no_name.str)
			val := C.LLVMConstInt(get_llvm_type_ref(symbols.int_symbol), lit.const_val.val as int, false)
			// _ := C.LLVMBuildStore(c.mod.builder.builder_ref, val, ref) 
			c.value_refs.prepend(val)
		}
		'string' {
			str_val :=  lit.const_val.val as string
			ptr := c.add_global_string_literal_ptr(str_val)
			
			c.value_refs.prepend(ptr)
		}
		else {
			// not supported yet
			panic('Cannot emit literal of type $typ')
		}
	}
}

fn (mut c Context) add_global_string_literal_ptr(str_val string) C.LLVMValueRef {
	ref := C.LLVMBuildGlobalString(c.mod.builder.builder_ref, str_val.str, no_name.str) 
	ptr := C.LLVMBuildPointerCast(
			c.mod.builder.builder_ref, 
			ref, 
			C.LLVMPointerType(C.LLVMInt8Type(), 0), 
			no_name.str) 
	return ptr
}

[inline]
fn get_llvm_type_ref(typ symbols.TypeSymbol) C.LLVMTypeRef {
	match typ.name {
		'int' {
			return C.LLVMInt32Type()
		}
		'string' {
			return C.LLVMPointerType(C.LLVMInt8Type(), 0)
		}
		else {return C.LLVMInt32Type()}
	}
}