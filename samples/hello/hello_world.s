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
	movl	$jmp_buf, %edi
	callq	setjmp
	testq	%rax, %rax
	je	.LBB0_1
# %bb.2:                                # %error_exit
	movl	$1, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.LBB0_1:                                # %continue
	.cfi_def_cfa_offset 16
	movl	$.L__unnamed_1, %edi
	movl	$.L__unnamed_2, %esi
	xorl	%eax, %eax
	callq	printf
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
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
	.asciz	"hello world"
	.size	.L__unnamed_2, 12

	.section	".note.GNU-stack","",@progbits
