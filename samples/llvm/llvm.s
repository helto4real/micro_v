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
	movl	$1, 12(%rsp)
	movq	$.L__unnamed_1, 16(%rsp)
	movl	$5, 8(%rsp)
	movl	$.L__unnamed_1, %edi
	callq	puts
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
	.asciz	"Tomas is \303\266 the greatest of them all <3"
	.size	.L__unnamed_1, 40

	.section	".note.GNU-stack","",@progbits
