module mod
import os
fn test_lookup_import_path_by_vmod() {
	test_dir := os.dir('${@FILE}')
	expected_dir := os.join_path(test_dir, 'tests/vmod/lib/a')
	b_file := os.join_path(test_dir, 'tests/vmod/lib/b/b.v')

	mod_path := mod_cache.lookup_module_path_by_file(b_file, 'lib.a')
	assert mod_path == expected_dir
}

fn test_lookup_import_path_by_current_folder() {
	test_dir := os.dir('${@FILE}')
	a_dir := os.join_path(test_dir, 'tests/vmod/lib/x.v')
	expected := os.join_path(test_dir, 'tests/vmod/lib/b')

	mod_path := mod_cache.lookup_module_path_by_file(a_dir, 'b')
	assert mod_path == expected
}

fn test_lookup_import_path_by_lib() {
	test_dir := os.dir('${@FILE}')
	b_file := os.join_path(test_dir, 'tests/vmod/lib/b/b.v')
	expected := os.join_path(mod_cache.lib_path, 'comp/ast')

	mod_path := mod_cache.lookup_module_path_by_file(b_file, 'comp.ast')
	assert mod_path == expected
}

fn test_lookup_real_module_name_vmod() {
	test_dir := os.dir('${@FILE}')
	b_file := os.join_path(test_dir, 'tests/vmod/lib/b/b.v')
	compile_file := os.join_path(test_dir, 'tests/vmod/lib/a')
	real_mod := mod_cache.lookup_full_module_name(compile_file, b_file, 'b')
	assert real_mod == 'lib.b'
}

fn test_lookup_real_module_name_by_folder() {
	test_dir := os.dir('${@FILE}')
	a_file := os.join_path(test_dir, 'tests/nomod/a/a.v')
	compile_file := os.join_path(test_dir, 'tests/nomod')
	real_mod := mod_cache.lookup_full_module_name(compile_file, a_file, 'a')
	assert real_mod == 'a'
}