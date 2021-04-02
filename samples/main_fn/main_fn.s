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
	je	.LBB0_2
# %bb.1:                                # %error_exit
	movl	$1, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.LBB0_2:                                # %continue
	.cfi_def_cfa_offset 16
	movl	$.L__unnamed_1, %edi
	movl	$.L__unnamed_2, %esi
	xorl	%eax, %eax
	callq	printf
	movl	$jmp_buf, %edi
	movl	$1, %esi
	callq	longjmp
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	sprintf_buff,@object    # @sprintf_buff
	.bss
	.globl	sprintf_buff
	.p2align	4
sprintf_buff:
	.zero	21
	.size	sprintf_buff, 21

	.type	jmp_buf,@object         # @jmp_buf
	.globl	jmp_buf
	.p2align	3
jmp_buf:
	.zero	8
	.size	jmp_buf, 8

	.type	.L__unnamed_2,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_2:
	.asciz	"fail on false"
	.size	.L__unnamed_2, 14

	.type	.L__unnamed_1,@object   # @1
.L__unnamed_1:
	.asciz	"%s\n"
	.size	.L__unnamed_1, 4

	.section	".note.GNU-stack","",@progbits
