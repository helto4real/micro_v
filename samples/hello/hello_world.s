	.text
	.file	"program"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movl	$jmp_buf, %edi
	callq	setjmp
	testq	%rax, %rax
	je	.LBB0_1
# %bb.2:                                # %error_exit
	movl	$1, %eax
	leaq	-8(%rbp), %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB0_1:                                # %continue
	.cfi_def_cfa %rbp, 16
	movq	%rsp, %rbx
	leaq	-32(%rbx), %rsp
	movq	$.L__unnamed_1, -16(%rbx)
	movq	$0, -24(%rbx)
	movl	$10, -32(%rbx)
	movl	$.L__unnamed_2, %edi
	movl	$.L__unnamed_3, %esi
	xorl	%eax, %eax
	callq	printf
	movl	-32(%rbx), %edi
	movq	-24(%rbx), %rsi
	movq	-16(%rbx), %rdx
	callq	do_test
	movl	$.L__unnamed_2, %edi
	movl	$.L__unnamed_4, %esi
	xorl	%eax, %eax
	callq	printf
	xorl	%eax, %eax
	leaq	-8(%rbp), %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	do_test                 # -- Begin function do_test
	.p2align	4, 0x90
	.type	do_test,@function
do_test:                                # @do_test
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, 8(%rsp)
	movl	%edi, (%rsp)
	movq	%rdx, 16(%rsp)
	movl	$.L__unnamed_2, %edi
	movq	%rdx, %rsi
	xorl	%eax, %eax
	callq	printf
	movq	16(%rsp), %rsi
	movl	$.L__unnamed_2, %edi
	xorl	%eax, %eax
	callq	printf
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	do_test, .Lfunc_end1-do_test
	.cfi_endproc
                                        # -- End function
	.type	jmp_buf,@object         # @jmp_buf
	.bss
	.globl	jmp_buf
	.p2align	3
jmp_buf:
	.zero	8
	.size	jmp_buf, 8

	.type	.L__unnamed_1,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_1:
	.asciz	"hello"
	.size	.L__unnamed_1, 6

	.type	.L__unnamed_2,@object   # @1
.L__unnamed_2:
	.asciz	"%s\n"
	.size	.L__unnamed_2, 4

	.type	.L__unnamed_5,@object   # @2
.L__unnamed_5:
	.asciz	"%s"
	.size	.L__unnamed_5, 3

	.type	.L__unnamed_3,@object   # @3
.L__unnamed_3:
	.asciz	"before exit"
	.size	.L__unnamed_3, 12

	.type	.L__unnamed_4,@object   # @4
.L__unnamed_4:
	.asciz	"after exit"
	.size	.L__unnamed_4, 11

	.section	".note.GNU-stack","",@progbits
