	.text
	.file	"program"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$1, 20(%rsp)
	movq	$.L__unnamed_1, 8(%rsp)
	movl	$5, 16(%rsp)
	movl	$.L__unnamed_2, %edi
	movl	$.L__unnamed_1, %esi
	xorl	%eax, %eax
	callq	printf
	movq	8(%rsp), %rsi
	movl	$.L__unnamed_3, %edi
	xorl	%eax, %eax
	callq	printf
	movl	$.L__unnamed_4, %edi
	movl	$.L__unnamed_5, %esi
	xorl	%eax, %eax
	callq	printf
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L__unnamed_1,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_1:
	.asciz	"Hellooo world!"
	.size	.L__unnamed_1, 15

	.type	.L__unnamed_2,@object   # @1
.L__unnamed_2:
	.asciz	"%s"
	.size	.L__unnamed_2, 3

	.type	.L__unnamed_3,@object   # @2
.L__unnamed_3:
	.asciz	"%s"
	.size	.L__unnamed_3, 3

	.type	.L__unnamed_5,@object   # @3
.L__unnamed_5:
	.zero	1
	.size	.L__unnamed_5, 1

	.type	.L__unnamed_4,@object   # @4
.L__unnamed_4:
	.asciz	"%s\n"
	.size	.L__unnamed_4, 4

	.section	".note.GNU-stack","",@progbits
