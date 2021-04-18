module core

#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Transforms/Scalar.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>

#flag -I/usr/lib/llvm-10/include -L/usr/lib/llvm-10/lib -L/lib/llvm-10/lib

// #flag -I llvm10/lib
#flag -l LLVM

enum LLVMVerifierFailureAction {
	llvm_abort_process_action = 0 // verifier will print to stderr and abort()
	llvm_print_message_action = 1 // verifier will print to stderr and return 1
	llvm_return_status_action = 2 // verifier will just return 1
}

[typedef]
enum LLVMValueKind {
	argument = 0
	basic_block
	memory_use
	memory_def
	memory_phi
	function
	global_alias
	global_ifunc
	global_variable
	block_address
	constant_expr
	constant_array
	constant_struct
	constant_vector
	undef_value
	constant_aggregate_zero
	constant_data_array
	constant_data_vector
	constant_int
	constant_fp
	constant_pointer_null
	constant_token_none
	metadata_as_value
	inline_asm
	instruction
}

pub enum LLVMTypeKind  {
	void = 0
	half
	float
	double
	x86_fp80
	fp128
	ppc_fp128
	label
	integer
	function
	_struct
	array
	pointer
	vector
	metadata
	x86_mmx
	token
} 

fn C.LLVMDumpValue(val &C.LLVMValueRef)
fn C.LLVMDumpType(val &C.LLVMTypeRef)
fn C.LLVMDumpModule(mod &C.LLVMModuleRef)
fn C.LLVMIsNull(val &C.LLVMValueRef) C.LLVMBool

[typedef]
pub struct C.LLVMBool {}

[typedef]
pub struct C.LLVMContextRef {}

[typedef]
pub struct C.LLVMModuleRef {}

[typedef]
pub struct C.LLVMTypeRef {}

[typedef]
pub struct C.LLVMValueRef {}

[typedef]
pub struct C.LLVMUseRef {}

[typedef]
pub struct C.LLVMBasicBlockRef {}

[typedef]
pub struct C.LLVMBuilderRef {}

[typedef]
pub struct C.LLVMExecutionEngineRef {}

[typedef]
pub struct C.LLVMMCJITCompilerOptions {}

[typedef]
pub struct C.LLVMGenericValueRef {}

[typedef]
pub struct C.LLVMPassManagerRef {}

[typedef]
pub struct C.LLVMOpaqueValue {}

fn C.LLVMInt1Type() &C.LLVMTypeRef
fn C.LLVMInt8Type() &C.LLVMTypeRef
fn C.LLVMInt16Type() &C.LLVMTypeRef
fn C.LLVMInt32Type() &C.LLVMTypeRef
fn C.LLVMInt64Type() &C.LLVMTypeRef
fn C.LLVMInt128Type() &C.LLVMTypeRef
fn C.LLVMVoidType() &C.LLVMTypeRef

fn C.LLVMInt1TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMInt8TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMInt16TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMInt32TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMInt64TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMInt128TypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef
fn C.LLVMIntTypeInContext(ctx_ref &C.LLVMContextRef, nr_bits int) &C.LLVMTypeRef
fn C.LLVMVoidTypeInContext(ctx_ref &C.LLVMContextRef) &C.LLVMTypeRef

fn C.LLVMGetValueKind(val &C.LLVMValueRef) LLVMValueKind//&C.LLVMValueKind
fn C.LLVMTypeOf(val &C.LLVMValueRef) &C.LLVMTypeRef
fn C.LLVMGetTypeKind(&C.LLVMTypeRef) LLVMTypeKind
fn C.LLVMGetTypeByName(mod &C.LLVMModuleRef, name &char) &C.LLVMTypeRef

fn C.LLVMGetIntTypeWidth(&C.LLVMTypeRef) int

// metadata
fn C.LLVMGetOrInsertNamedMetadata(mod &C.LLVMModuleRef, name &char, name_len u32) &C.LLVMNamedMDNodeRef
fn C.LLVMSetMetadata(val &C.LLVMValueRef, kind_id u32, node &C.LLVMValueRef)
fn C.LLVMSetModuleInlineAsm2(mod &C.LLVMModuleRef, name &char, name_len u32)

// array
fn C.LLVMArrayType(elem_typ &C.LLVMTypeRef, len u32) &C.LLVMTypeRef
fn C.LLVMConstArray(elem_typ &C.LLVMTypeRef, values voidptr, len u32) &C.LLVMValueRef
fn C.LLVMGetArrayLength(typ_ref &C.LLVMTypeRef) int
// structs

fn C.LLVMStructTypeInContext(ctx &C.LLVMContextRef, type_refs voidptr, elem_count u32, packed C.LLVMBool) &C.LLVMTypeRef
fn C.LLVMStructCreateNamed(ctx &C.LLVMContextRef, name &char) &C.LLVMTypeRef
fn C.LLVMStructSetBody(struct_typ_ref &C.LLVMTypeRef, element_types voidptr, element_count u32, packed C.LLVMBool)
fn C.LLVMConstStructInContext(ctx &C.LLVMContextRef, values voidptr, count u32, packed int) &C.LLVMValueRef

fn C.LLVMConstNamedStruct(struct_typ &C.LLVMTypeRef, value_refs voidptr, count u32) &C.LLVMValueRef
fn C.LLVMConstNull(typ_ref &C.LLVMTypeRef) &C.LLVMValueRef
fn C.LLVMBuildStructGEP2(builder &C.LLVMBuilderRef, typ_ref &C.LLVMTypeRef, val_ref &C.LLVMValueRef, idx u32, name &char) &C.LLVMValueRef

fn C.LLVMBuildInBoundsGEP2(builder &C.LLVMBuilderRef, typ_ref &C.LLVMTypeRef, val_ref &C.LLVMValueRef, indicies voidptr, nr_indicies u32, name &char) &C.LLVMValueRef

// fn C.LLVMBuildPointerCast(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, dest_typ &C.LLVMTypeRef, name charptr) &C.LLVMValueRef

fn C.LLVMModuleCreateWithName(&char) &C.LLVMModuleRef

// functions
fn C.LLVMFunctionType(return_type &C.LLVMTypeRef, param_types voidptr, param_count int, is_var_arg C.LLVMBool) &C.LLVMTypeRef
fn C.LLVMAddFunction(mod &C.LLVMModuleRef, name &char, fn_type &C.LLVMTypeRef) &C.LLVMValueRef
fn C.LLVMGetParam(func &C.LLVMValueRef, index int) &C.LLVMValueRef
fn C.LLVMIsFunctionVarArg(typ_ref &C.LLVMTypeRef) C.LLVMBool
fn C.LLVMGetReturnType(typ_ref &C.LLVMTypeRef) &C.LLVMTypeRef
fn C.LLVMCountParamTypes(typ_ref &C.LLVMTypeRef) int

fn C.LLVMBuildCall2(builder &C.LLVMBuilderRef, typ &C.LLVMTypeRef, func &C.LLVMValueRef, args_ptr voidptr, nr_of_args int, name &char) &C.LLVMValueRef
fn C.LLVMBuildCall(builder &C.LLVMBuilderRef, func &C.LLVMValueRef, args_ptr voidptr, nr_of_args int, name &char) &C.LLVMValueRef

fn C.LLVMBuildUnreachable(builder &C.LLVMBuilderRef) &C.LLVMValueRef

fn C.LLVMAppendBasicBlock(func &C.LLVMValueRef, name &char) &C.LLVMBasicBlockRef

fn C.LLVMCreateBuilder() &C.LLVMBuilderRef

fn C.LLVMPositionBuilderAtEnd(builder &C.LLVMBuilderRef, block &C.LLVMBasicBlockRef)

// uses
fn C.LLVMGetFirstUse(val &C.LLVMValueRef) &C.LLVMUseRef
fn C.LLVMGetNextUse(use &C.LLVMUseRef) &C.LLVMUseRef

// binary operators
fn C.LLVMBuildBinOp(builder &C.LLVMBuilderRef, op_code Opcode, left &C.LLVMValueRef, right &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildAdd(builder &C.LLVMBuilderRef, lhs &C.LLVMValueRef, rhs &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildSub(builder &C.LLVMBuilderRef, lhs &C.LLVMValueRef, rhs &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildMul(builder &C.LLVMBuilderRef, lhs &C.LLVMValueRef, rhs &C.LLVMValueRef, name &char) &C.LLVMValueRef

fn C.LLVMGetParams(func &C.LLVMValueRef, params &LLVMValueRef)
fn C.LLVMGetParam(func &C.LLVMValueRef, index int) &C.LLVMValueRef

// return with and without value
fn C.LLVMBuildRet(ref &C.LLVMBuilderRef, val &C.LLVMValueRef) &C.LLVMValueRef
fn C.LLVMBuildRetVoid(builder &C.LLVMBuilderRef) &C.LLVMValueRef

fn C.LLVMDisposeBuilder(builder &C.LLVMBuilderRef)
fn C.LLVMVerifyModule(mod &C.LLVMModuleRef, action LLVMVerifierFailureAction, err_msg &char) C.LLVMBool

// output
fn C.LLVMWriteBitcodeToFile(mod &C.LLVMModuleRef, path &char) int
fn C.LLVMPrintModuleToFile(mod &C.LLVMModuleRef, path &char, err_msg &char) int

// allocation ans store
fn C.LLVMBuildAlloca(builder &C.LLVMBuilderRef, typ &C.LLVMTypeRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildArrayAlloca(builder &C.LLVMBuilderRef, typ &C.LLVMTypeRef,
                                  val &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildStore(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, val_ref &C.LLVMValueRef) &C.LLVMValueRef

fn C.LLVMConstInt(type_ref &C.LLVMTypeRef, val u64, sign_extend C.LLVMBool) &C.LLVMValueRef

fn C.LLVMAddGlobal(mod &C.LLVMModuleRef, typ_ref &C.LLVMTypeRef, name &char) &C.LLVMValueRef
fn C.LLVMGetNamedGlobal(mod &C.LLVMModuleRef, name &char) &C.LLVMValueRef
fn C.LLVMSetInitializer(var &C.LLVMValueRef, const_val &C.LLVMValueRef)

fn C.LLVMBuildGlobalString(builder &C.LLVMBuilderRef, str &char, name &char) &C.LLVMValueRef
fn C.LLVMBuildGlobalStringPtr(builder &C.LLVMBuilderRef, str &char, name &char) &C.LLVMValueRef
fn C.LLVMGetLastInstruction(blocl &C.LLVMBasicBlockRef) &C.LLVMValueRef

fn C.LLVMBuildNeg(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildNSWNeg(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildNot(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, name &char) &C.LLVMValueRef

fn C.LLVMBuildLoad2(builder &C.LLVMBuilderRef, typ_ref &C.LLVMTypeRef, val_ref &C.LLVMValueRef, name &char) &C.LLVMValueRef

// pointers
fn C.LLVMPointerType(element_type &C.LLVMTypeRef, address_space u32) &C.LLVMTypeRef
fn C.LLVMBuildPointerCast(builder &C.LLVMBuilderRef, val &C.LLVMValueRef, dest_type &C.LLVMTypeRef, name &char) &C.LLVMValueRef
fn C.LLVMBuildIntToPtr(builder &C.LLVMBuilderRef, val &C.LLVMValueRef,
                            to_type &C.LLVMTypeRef, name &char) &C.LLVMValueRef 
fn C.LLVMConstIntToPtr(const_val &C.LLVMValueRef, to_type &C.LLVMTypeRef ) &C.LLVMValueRef
fn C.LLVMGetElementType(typ &C.LLVMTypeRef) &C.LLVMTypeRef
// cast operations
fn C.LLVMBuildIntCast2(builder &C.LLVMBuilderRef, val &C.LLVMValueRef,
                            to_typ &C.LLVMTypeRef, is_signed C.LLVMBool,
                            name &char) &C.LLVMValueRef
fn C.LLVMGenericValueToInt(gen_val &C.LLVMGenericValueRef, is_signed C.LLVMBool) u64

fn C.LLVMBuildBr(builder &C.LLVMBuilderRef, dest &C.LLVMBasicBlockRef) &C.LLVMValueRef
fn C.LLVMBuildCondBr(builder &C.LLVMBuilderRef, cond &C.LLVMValueRef, then_block &C.LLVMBasicBlockRef, else_block &C.LLVMBasicBlockRef) &C.LLVMValueRef

// Context specific functions and structs

fn C.LLVMGetModuleContext(mod &C.LLVMModuleRef) &C.LLVMContextRef
fn C.LLVMGetTypeContext(typ &C.LLVMTypeRef) &C.LLVMContextRef
fn C.LLVMContextCreate() &C.LLVMContextRef
fn C.LLVMGetGlobalContext() &C.LLVMContextRef
fn C.LLVMContextDispose(ctx &C.LLVMContextRef)
fn C.LLVMModuleCreateWithNameInContext(mod_id &char, ctx_ref &C.LLVMContextRef) &C.LLVMModuleRef
fn C.LLVMDisposeModule(mod_ref &C.LLVMModuleRef)
fn C.LLVMCreateBuilderInContext(ctx_ref &C.LLVMContextRef) &C.LLVMBuilderRef

// basic blocks
fn C.LLVMAppendBasicBlockInContext(ctx_ref &C.LLVMContextRef, func &C.LLVMValueRef, name &char) &C.LLVMBasicBlockRef
fn C.LLVMInsertBasicBlockInContext(ctx_ref &C.LLVMContextRef, bb &C.LLVMBasicBlockRef, name &char) &C.LLVMBasicBlockRef
fn C.LLVMMoveBasicBlockAfter(block &C.LLVMBasicBlockRef, move_after_block &C.LLVMBasicBlockRef)
fn C.LLVMMoveBasicBlockBefore(block &C.LLVMBasicBlockRef, move_after_block &C.LLVMBasicBlockRef)
fn C.LLVMGetLastBasicBlock(func_ref &C.LLVMValueRef) &C.LLVMBasicBlockRef

// comparations

fn C.LLVMBuildICmp(builder &C.LLVMBuilderRef, op IntPredicate, left &C.LLVMValueRef, right &C.LLVMValueRef, name &char) &C.LLVMValueRef

fn C.LLVMGetLastInstruction(block &C.LLVMBasicBlockRef) &C.LLVMValueRef

// type checks and conversions
fn C.LLVMIsATerminatorInst(inst &C.LLVMValueRef) &C.LLVMValueRef
fn C.LLVMIsConstant(val &C.LLVMValueRef) C.LLVMBool
fn C.LLVMIsUndef(val &C.LLVMValueRef) C.LLVMBool
fn C.LLVMIsConstantString(val &C.LLVMValueRef) C.LLVMBool
fn C.LLVMIsAArgument(val &C.LLVMValueRef) &C.LLVMValueRef
fn C.LLVMIsAConstant(val &C.LLVMValueRef) &C.LLVMValueRef

fn C.LLVMConstPointerNull(typ_ref &C.LLVMTypeRef) &C.LLVMValueRef

// Exectution engeine and JIT
fn C.LLVMLinkInMCJIT()
fn C.LLVMInitializeNativeTarget() int
fn C.LLVMInitializeNativeAsmPrinter() int
fn C.LLVMInitializeNativeAsmParser() int

fn C.LLVMRemoveModule(exec_engine &C.LLVMExecutionEngineRef, mod &C.LLVMModuleRef, out_mod voidptr, err &char) int

fn C.LLVMCreateMCJITCompilerForModule(out_ref &&C.LLVMExecutionEngineRef, nid &C.LLVMModuleRef, opt &C.LLVMMCJITCompilerOptions, size_of_opt u32, err &char) int

fn C.LLVMDisposeExecutionEngine(exec_engine &C.LLVMExecutionEngineRef)

fn C.LLVMRunFunction(engine &C.LLVMExecutionEngineRef, func_ref &C.LLVMValueRef, nr_args u32, args voidptr) &C.LLVMGenericValueRef



// optimization passes
fn C.LLVMCreatePassManager() &C.LLVMPassManagerRef
fn C.LLVMRunPassManager(pass_ref &C.LLVMPassManagerRef, mod &C.LLVMModuleRef) int
fn C.LLVMAddInstructionCombiningPass(pass_ref &C.LLVMPassManagerRef)
fn C.LLVMAddReassociatePass(pass_ref &C.LLVMPassManagerRef)
fn C.LLVMAddGVNPass(pass_ref &C.LLVMPassManagerRef)
fn C.LLVMAddNewGVNPass(pass_ref &C.LLVMPassManagerRef)
fn C.LLVMAddDCEPass(pass_ref &C.LLVMPassManagerRef)
fn C.LLVMAddAggressiveDCEPass(pass_ref &C.LLVMPassManagerRef)

fn C.LLVMAddInternalizePass(pass_ref &C.LLVMPassManagerRef, all_but_main int)
fn C.LLVMAddGlobalDCEPass(pass_ref &C.LLVMPassManagerRef)

// enums
pub enum IntPredicate {
	int_eq = 32 //*< equal
	int_ne //*< not equal
	int_u_gt //*< unsigned greater than
	int_u_ge //*< unsigned greater or equal
	int_u_lt //*< unsigned less than
	int_u_le //*< unsigned less or equal
	int_s_gt //*< signed greater than
	int_s_ge //*< signed greater or equal
	int_s_lt //*< signed less than
	int_s_le //*< signed less or equal
}

pub enum Opcode {
	// Terminator Instructions
	// llvm_ret            = 1
	// llvm_Br             = 2
	// llvm_Switch         = 3
	// llvm_IndirectBr     = 4
	// llvm_Invoke         = 5
	// /* removed 6 due to API changes */
	// llvm_Unreachable    = 7
	// llvm_CallBr         = 67
	// Standard Unary Operators
	// llvm_FNeg           = 66
	// Standard Binary Operators
	llvm_add = 8
	// llvm_FAdd           = 9
	llvm_sub = 10
	// llvm_FSub           = 11
	llvm_mul = 12
	// llvm_FMul           = 13
	llvm_udiv = 14
	// llvm_SDiv           = 15
	// llvm_FDiv           = 16
	// llvm_URem           = 17
	// llvm_SRem           = 18
	// llvm_FRem           = 19
	// Logical Operators
	// llvm_Shl            = 20
	// llvm_LShr           = 21
	// llvm_AShr           = 22
	// llvm_And            = 23
	// llvm_Or             = 24
	// llvm_Xor            = 25
	// /* Memory Operators */
	// llvm_Alloca         = 26
	// llvm_Load           = 27
	// llvm_Store          = 28
	// llvm_GetElementPtr  = 29
	// /* Cast Operators */
	// llvm_Trunc          = 30
	// llvm_ZExt           = 31
	// llvm_SExt           = 32
	// llvm_FPToUI         = 33
	// llvm_FPToSI         = 34
	// llvm_UIToFP         = 35
	// llvm_SIToFP         = 36
	// llvm_FPTrunc        = 37
	// llvm_FPExt          = 38
	// llvm_PtrToInt       = 39
	// llvm_IntToPtr       = 40
	// llvm_BitCast        = 41
	// llvm_AddrSpaceCast  = 60
	// /* Other Operators */
	// llvm_ICmp           = 42
	// llvm_FCmp           = 43
	// llvm_PHI            = 44
	// llvm_Call           = 45
	// llvm_Select         = 46
	// llvm_UserOp1        = 47
	// llvm_UserOp2        = 48
	// llvm_VAArg          = 49
	// llvm_ExtractElement = 50
	// llvm_InsertElement  = 51
	// llvm_ShuffleVector  = 52
	// llvm_ExtractValue   = 53
	// llvm_InsertValue    = 54
	// llvm_Freeze         = 68
	// /* Atomic operators */
	// llvm_Fence          = 55
	// llvm_AtomicCmpXchg  = 56
	// llvm_AtomicRMW      = 57
	// /* Exception Handling Operators */
	// llvm_Resume         = 58
	// llvm_LandingPad     = 59
	// llvm_CleanupRet     = 61
	// llvm_CatchRet       = 62
	// llvm_CatchPad       = 63
	// llvm_CleanupPad     = 64
	// llvm_CatchSwitch    = 65
}
