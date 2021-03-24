	.text
	.file	"program"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	movq	$.L__unnamed_1, 32(%rsp)
	movq	$.L__unnamed_1, 24(%rsp)
	movq	$.L__unnamed_2, 16(%rsp)
	movq	$.L__unnamed_2, 8(%rsp)
	movl	$.L__unnamed_3, %edi
	movl	$.L__unnamed_1, %esi
	xorl	%eax, %eax
	callq	printf
	movl	$.L__unnamed_3, %edi
	movl	$.L__unnamed_4, %esi
	xorl	%eax, %eax
	callq	printf
	movq	8(%rsp), %rsi
	movl	$.L__unnamed_5, %edi
	xorl	%eax, %eax
	callq	printf
	xorl	%eax, %eax
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L__unnamed_1,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_1:
	.asciz	"helloo"
	.size	.L__unnamed_1, 7

	.type	.L__unnamed_6,@object   # @1
.L__unnamed_6:
	.asciz	"world"
	.size	.L__unnamed_6, 6

	.type	.L__unnamed_7,@object   # @2
.L__unnamed_7:
	.asciz	"hello"
	.size	.L__unnamed_7, 6

	.type	.L__unnamed_2,@object   # @3
.L__unnamed_2:
	.asciz	"world"
	.size	.L__unnamed_2, 6

	.type	.L__unnamed_5,@object   # @4
.L__unnamed_5:
	.asciz	"%s\n"
	.size	.L__unnamed_5, 4

	.type	.L__unnamed_3,@object   # @5
.L__unnamed_3:
	.asciz	"%s"
	.size	.L__unnamed_3, 3

	.type	.L__unnamed_4,@object   # @6
.L__unnamed_4:
	.asciz	" "
	.size	.L__unnamed_4, 2

	.section	".note.GNU-stack","",@progbits
