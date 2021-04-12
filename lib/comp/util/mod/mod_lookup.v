module mod

import os

const (
	mod_file_stop_paths = ['.git', '.hg', '.svn', '.v.mod.stop']
)

[heap]
pub struct ModuleCache {
mut:
	modules map[string]string
	vmod_paths map[string]string
pub mut:
	lib_path string
	current_dir string

}

pub fn new_mod_cache() &ModuleCache {
	file_dir := os.dir('${@FILE}')
    lib_path := file_dir[..file_dir.len-14]
	return &ModuleCache{
		lib_path: lib_path
		current_dir:  os.getwd()
		}
}

pub fn (mut mc ModuleCache) lookup_module_path_by_file(path string, import_name string) string {
	return mc.lookup_module_path_by_folder(os.dir(path), import_name)
}

pub fn (mut mc ModuleCache) lookup_module_path_by_folder(path string, import_name string) string {
	real_path := os.real_path(path)
	if real_path in mc.modules {
		return mc.modules[import_name]
	}
	import_path := get_module_path(import_name)
	// check local directory and current path first
	// and add the path to the folder of first found 
	// v.mod file 
	mut lookup_paths := [real_path, mc.current_dir, mc.lib_path]
	path_to_vmod := mc.lookup_v_mod_by_folder(real_path)
	if path_to_vmod.len > 0 {
		lookup_paths << path_to_vmod
	}
	for p in lookup_paths {
		mod_folder_path := os.join_path(p, import_path)
		if os.is_dir(mod_folder_path) {
			mc.modules[import_name] = mod_folder_path
			return mod_folder_path
		}
	}
	// traverse up using parents
	return ''
}
pub fn (mut mc ModuleCache) lookup_v_mod_by_folder(path string) string {
	$if windows {
		// windows root path is C: or D:
		if path.len <= 2 {
			return ''
		}
	} $else {
		if path.len == 0 {
			return ''
		}
	}
	if path in mc.vmod_paths {
		// the path is in the cache 
		return mc.vmod_paths[path]
	}
	files := os.ls(path) or { 
		[]string{}
		}
	if 'v.mod' in files {
		mc.vmod_paths[path] = path
		return path
	}

	// no vmod files found so continue traversing parent
	parent_folder := os.dir(path)
	vmod_path := mc.lookup_v_mod_by_folder(parent_folder) 

	if vmod_path.len > 0 {
		// add all parent 
		mc.vmod_paths[path] = vmod_path
		return vmod_path
	}
	return vmod_path
}

// lookup_full_module_name finds the first occurrence of a v.mod file
pub fn (mut mc ModuleCache) lookup_full_module_name(start_folder string, file_path string, module_name string) string {
	real_path := os.real_path(os.dir(file_path))

	real_start_folder_name := os.real_path(start_folder)
	if real_path.starts_with(start_folder) {
		if real_start_folder_name.len >= real_path.len {
			return module_name
		}
		mod_path := real_path[real_start_folder_name.len+1..]
		if mod_path.starts_with('home') {
			println('$start_folder, $real_start_folder_name : $real_path')
		}
		return get_module_name_from_path(mod_path)
	}

	vmod_path := mc.lookup_v_mod_by_folder(real_path)

	if vmod_path.len > 1 {
		// we gound a v.mod file so this is the path for 
		// calculating the module name
		if vmod_path.len >= real_path.len {
			return module_name
		}
		mod_path := real_path[vmod_path.len+1..]
		if mod_path.starts_with('home') {
			println('HOOOME2')
		}
		return get_module_name_from_path(mod_path)
	}


	return ''
}

pub const(
	mod_cache = new_mod_cache()
)

pub fn get_mod_cache() &ModuleCache {
	return mod_cache
}
[inline]
fn get_module_path(mod string) string {
	return mod.replace('.', os.path_separator)
}

[inline]
fn get_module_name_from_path(mod_path string) string {
	return mod_path.replace(os.path_separator, '.')
}