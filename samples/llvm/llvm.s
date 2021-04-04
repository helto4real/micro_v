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
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movq	$.L__unnamed_1, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movq	$.L__unnamed_1, -16(%rax)
	movq	%rsp, %rcx
	leaq	-16(%rcx), %rsp
	movq	$.L__unnamed_2, -16(%rcx)
	movq	%rsp, %rbx
	leaq	-16(%rbx), %rsp
	movq	$.L__unnamed_2, -16(%rbx)
	movq	-16(%rax), %rsi
	movl	$.L__unnamed_3, %edi
	xorl	%eax, %eax
	callq	printf
	movl	$.L__unnamed_3, %edi
	movl	$.L__unnamed_4, %esi
	xorl	%eax, %eax
	callq	printf
	movq	-16(%rbx), %rsi
	movl	$.L__unnamed_5, %edi
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
	.type	jmp_buf,@object         # @jmp_buf
	.bss
	.globl	jmp_buf
	.p2align	3
jmp_buf:
	.zero	8
	.size	jmp_buf, 8

	.type	sprintf_buff,@object    # @sprintf_buff
	.globl	sprintf_buff
	.p2align	4
sprintf_buff:
	.zero	21
	.size	sprintf_buff, 21

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
