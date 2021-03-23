	.text
	.file	"program"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$0, (%rsp)
	movl	$5, 4(%rsp)
	jmp	.LBB0_5
	.p2align	4, 0x90
.LBB0_4:                                # %Continue_1
                                        #   in Loop: Header=BB0_5 Depth=1
	incl	(%rsp)
.LBB0_5:                                # %Label_4
                                        # =>This Inner Loop Header: Depth=1
	movl	(%rsp), %eax
	cmpl	4(%rsp), %eax
	jge	.LBB0_6
# %bb.1:                                # %Body_2
                                        #   in Loop: Header=BB0_5 Depth=1
	cmpl	$2, (%rsp)
	je	.LBB0_4
# %bb.2:                                # %End_6
                                        #   in Loop: Header=BB0_5 Depth=1
	cmpl	$4, (%rsp)
	je	.LBB0_6
# %bb.3:                                # %End_8
                                        #   in Loop: Header=BB0_5 Depth=1
	movl	$.L__unnamed_1, %edi
	movl	$.L__unnamed_2, %esi
	xorl	%eax, %eax
	callq	printf
	jmp	.LBB0_4
.LBB0_6:                                # %Break_3
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
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
	.asciz	"tomas"
	.size	.L__unnamed_2, 6

	.section	".note.GNU-stack","",@progbits
