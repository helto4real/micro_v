	.text
	.file	"program"
	.globl	do_test                 # -- Begin function do_test
	.p2align	4, 0x90
	.type	do_test,@function
do_test:                                # @do_test
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	%edi, 8(%rsp)
	movq	%rsi, 16(%rsp)
	movl	$.L__unnamed_1, %edi
	xorl	%eax, %eax
	callq	printf
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
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
	movq	$.L__unnamed_2, 16(%rsp)
	movl	$200, 8(%rsp)
	movl	$.L__unnamed_2, %esi
	movl	$200, %edi
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
	.asciz	"%s\n"
	.size	.L__unnamed_1, 4

	.type	.L__unnamed_3,@object   # @1
.L__unnamed_3:
	.asciz	"%s"
	.size	.L__unnamed_3, 3

	.type	.L__unnamed_2,@object   # @2
.L__unnamed_2:
	.asciz	"hello"
	.size	.L__unnamed_2, 6

	.section	".note.GNU-stack","",@progbits
