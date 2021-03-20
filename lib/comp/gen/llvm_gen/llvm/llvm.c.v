module llvm

#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>

#flag -I/usr/lib/llvm-10/include -L/usr/lib/llvm-10/lib -L/lib/llvm-10/lib

// #flag -I llvm10/lib
#flag -l LLVM

enum LLVMVerifierFailureAction {
  llvm_abort_process_action = 0 /* verifier will print to stderr and abort() */
  llvm_print_message_action = 1 /* verifier will print to stderr and return 1 */
  llvm_return_status_action = 2 /* verifier will just return 1 */
}

[typedef] pub struct C.LLVMBool {} 

[typedef] pub struct C.LLVMModuleRef {}
[typedef] pub struct C.LLVMTypeRef{}
[typedef] pub struct C.LLVMValueRef{}
[typedef] pub struct C.LLVMBuilderRef{}
[typedef] pub struct C.LLVMExecutionEngineRef{}

fn C.LLVMInt1Type() C.LLVMTypeRef
fn C.LLVMInt8Type() C.LLVMTypeRef
fn C.LLVMInt16Type() C.LLVMTypeRef
fn C.LLVMInt32Type() C.LLVMTypeRef
fn C.LLVMInt64Type() C.LLVMTypeRef
fn C.LLVMInt128Type() C.LLVMTypeRef
// fn C. LLVMIntType(unsigned NumBits) LLVMTypeRef

fn C.LLVMModuleCreateWithName(charptr) C.LLVMModuleRef
fn C.LLVMFunctionType(ReturnType C.LLVMTypeRef, param_types voidptr , param_count int,
                            is_var_arg int) C.LLVMTypeRef

fn C.LLVMAddFunction(mod C.LLVMModuleRef, name charptr, fn_type C.LLVMTypeRef ) C.LLVMValueRef

fn C.LLVMAppendBasicBlock(func C.LLVMValueRef, name charptr) C.LLVMBasicBlockRef

fn C.LLVMCreateBuilder() C.LLVMBuilderRef

fn C.LLVMPositionBuilderAtEnd(builder C.LLVMBuilderRef, block C.LLVMBasicBlockRef)

fn C.LLVMBuildAdd(builder C.LLVMBuilderRef, lhs C.LLVMValueRef, rhs C.LLVMValueRef,
		name charptr) C.LLVMValueRef

fn C.LLVMGetParams(func C.LLVMValueRef, params &LLVMValueRef)
fn C.LLVMGetParam(func C.LLVMValueRef, index int) C.LLVMValueRef
fn C.LLVMBuildRet(ref C.LLVMBuilderRef, val C.LLVMValueRef ) C.LLVMValueRef
fn C.LLVMDisposeBuilder(builder C.LLVMBuilderRef)
fn C.LLVMVerifyModule(mod C.LLVMModuleRef, action LLVMVerifierFailureAction,
                          err_msg charptr) int //C.LLVMBool

fn C.LLVMWriteBitcodeToFile(mod C.LLVMModuleRef, path charptr) int
fn C.LLVMPrintModuleToFile(mod C.LLVMModuleRef, path charptr, err_msg charptr) int

