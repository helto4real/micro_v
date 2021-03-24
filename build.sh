v lib/comp/gen/llvm_gen/test_llvm.v
lib/comp/gen/llvm_gen/test_llvm
llc -O3 ./test.ll
clang -o test test.s
./test
echo $?
