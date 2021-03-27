	.text
	.file	"program"
	.globl	do_test                 # -- Begin function do_test
	.p2align	4, 0x90
	.type	do_test,@function
do_test:                                # @do_test
	.cfi_startproc
# %bb.0:                                # %entry
	movq	%rsi, -8(%rsp)
	movl	%edi, -16(%rsp)
	retq
.Lfunc_end0:
	.size	do_test, .Lfunc_end0-do_test
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	$.L__unnamed_1, 16(%rsp)
	movl	$100, 8(%rsp)
	movl	$.L__unnamed_1, %esi
	movl	$100, %edi
	callq	do_test
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.L__unnamed_1,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_1:
	.asciz	"hello"
	.size	.L__unnamed_1, 6

	.section	".note.GNU-stack","",@progbits
