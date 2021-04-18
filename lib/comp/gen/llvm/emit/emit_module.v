
module emit

// import term
import lib.comp.symbols
import lib.comp.binding
import lib.comp.gen.llvm.core

[heap]
pub struct EmitModule {
pub mut:
	exec_engine &core.ExecutionEngine =0
	pass_manager &core.PassManager = 0
	mod core.Module
	ctx core.Context
	bld core.Builder

	is_test bool

	global_const map[GlobalVarRefType]core.Value
	built_in_funcs []core.Value
	funcs []&FunctionDecl
	var_decl map[string]core.Value
	types map[string]core.Type

	main_func_val core.Value
	// global variables that are convenient to have access to
}

pub fn new_emit_module(name string) &EmitModule {
	ctx := core.new_context()

	return &EmitModule {
		mod: ctx.new_module(name)
		ctx: ctx
		bld: ctx.new_builder()
	}
}

pub fn (mut em EmitModule) dispose() {
	if em.exec_engine != 0 {
		// if exec engine exists we need to remove the module
		// before you can dispose the engine and the module		
		em.exec_engine.remove_module(em.mod) or {panic('failed to remove module')}
		
		em.exec_engine.dispose()
	}
	em.bld.dispose()

	em.mod.dispose()
	em.ctx.dispose()
}

pub fn (mut em EmitModule) init_execution_engine() ? {
	core.link_in_mc_jit() 
	core.initialize_native_target() 
	core.initialize_native_asm_printer() 
	core.initialize_native_asm_parser() 
	em.exec_engine = em.mod.create_mc_jit_compiler() ?
}

pub fn (em &EmitModule) write_to_file(path string) ? {
	return em.mod.write_to_file(path)
}

pub fn (em &EmitModule) print_to_file(path string) ? {
	return em.mod.print_to_file(path)
}

pub fn (mut em EmitModule) run_main() i64 {
	em.init_execution_engine() or { panic('error init execution enging : $err.msg') }
	if em.exec_engine == 0 {
		panic('unexpected, execution engine have to be initialized before calling run_main')
	}
	mainfunc_val := em.funcs.filter(it.name=='main')[0].val 
	res := em.exec_engine.run_function(mainfunc_val)
	return i64(res.int(true))
}

pub fn (mut em EmitModule) emit_struct_decl(program &binding.BoundProgram) {
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			mut struct_name := typ.name
			if typ.is_c_decl && typ.members.len == 0 {
				// remove the C. in the name when whe have opaque type
				// defined in a library
				name_parts := struct_name.split('.')
				struct_name = name_parts[name_parts.len-1]
			}
			em.types[typ.name] = em.ctx.new_named_struct_type(struct_name)
		}
	}
}

pub fn (mut em EmitModule) emit_c_fn_decl(program &binding.BoundProgram) {
	for i, func in program.func_symbols {
		if func.is_c_decl {
			em.declare_fn(&program.func_symbols[i], binding.new_empty_block_stmt())
		}
	}
}

pub fn (mut em EmitModule) emit_struct_bodies(program &binding.BoundProgram) {
	for _, typ in program.types {
		if typ is symbols.StructTypeSymbol {
			struct_type := em.get_type_from_type_symb(typ)
			mut types := []core.Type{}
			for member in typ.members {
				member_typ := em.get_type_from_type_symb(member.typ)
				if member.typ.is_ref {
					types << member_typ.to_pointer_type(0)
				} else {
					types << member_typ
				}
			}
			if types.len > 0 {
				struct_type.struct_set_body(types, false)	
			}
		}
	}	
}

pub fn (mut em EmitModule) emit_main_fn(program &binding.BoundProgram) {
	if em.is_test == false {
		body := program.func_bodies[program.main_func.id] or {
			// No main defined or global statements
			panic('unexpected, function body for $program.main_func.name ($program.main_func.id) missing')
		}
		lowered_body := binding.lower(body)
		em.main_func_val = em.declare_fn(&program.main_func, lowered_body).val
	} else {
		test_main := symbols.new_function_symbol('main', 'main', []symbols.ParamSymbol{},
			symbols.int_symbol)
		body := binding.new_empty_block_stmt()
		em.main_func_val = em.declare_fn(&test_main, body).val
	}
}

pub fn (mut em EmitModule) emit_fn_decl(program &binding.BoundProgram) {
	// first declare all functions except the main and C declares
	for i, func in program.func_symbols {
		if func.name != 'main' && !func.is_c_decl {
			// this is a normal function, expect a body
			body := program.func_bodies[func.id] or {
				panic('unexpected, function body for $func.name ($func.id) missing')
			}
			lowered_body := binding.lower(body)
			em.declare_fn(&program.func_symbols[i], lowered_body)
		}
	}
}
pub fn (mut em EmitModule) emit_main_fn_body() {
	for i, _ in em.funcs {
		mut ff := em.funcs[i]
		if ff.func.name == 'main' {
			ff.emit_body()
		}
	}
}

pub fn (mut em EmitModule) emit_fn_bodies() {
	for i,_ in em.funcs {
		mut ff := em.funcs[i]
		if ff.func.name != 'main' && !ff.func.is_c_decl{
			ff.emit_body()
		}
	}
}
pub fn (mut em EmitModule) generate_module(program &binding.BoundProgram, is_test bool) {
	em.is_test = is_test
	// emit globals and standard functions
	// em.emit_global_types()
	// em.emit_standard_funcs()
	
	// emit program structs and functions
	em.emit_struct_decl(program)
	em.emit_c_fn_decl(program)
	em.emit_global_vars()
	em.emit_struct_bodies(program)
	em.emit_main_fn(program)
	em.emit_fn_decl(program)

	// finally emit function bodies
	em.emit_main_fn_body()
	em.emit_fn_bodies()


}

pub fn (mut em EmitModule) verify() ? {
	// return none
	em.mod.verify() ?
}

pub fn (mut em EmitModule) optimize() {
	em.pass_manager = core.new_pass_manager()
	em.pass_manager.add_internalize_pass()
	em.pass_manager.add_dce_pass()
	em.pass_manager.add_instruction_combining_pass()
	em.pass_manager.add_reassociate_pass()
	em.pass_manager.add_gvn_pass()
	em.pass_manager.add_global_dce_pass()
	em.pass_manager.run_pass_manager(em.mod)
}

pub fn dump_value(val core.Value) {
	print('dump value: ')
	val.dump_value()
	kind := val.value_kind()
	typ := val.typ()
	typ_kind := val.typ().type_kind()
	print(' (')
	typ.dump_type()
	println('), kind: $kind, typ_kind: $typ_kind')
}