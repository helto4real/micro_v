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
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	variadic                # -- Begin function variadic
	.p2align	4, 0x90
	.type	variadic,@function
variadic:                               # @variadic
	.cfi_startproc
# %bb.0:                                # %entry
	movl	%edi, -12(%rsp)
	movq	%rsi, -8(%rsp)
	retq
.Lfunc_end1:
	.size	variadic, .Lfunc_end1-variadic
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

	.section	".note.GNU-stack","",@progbits
