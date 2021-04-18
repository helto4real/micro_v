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
	movabsq	$jmp_buf, %rdi
	callq	setjmp
	cmpq	$0, %rax
	jne	.LBB0_2
# %bb.1:                                # %continue
	callq	test_mutable_param
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.LBB0_2:                                # %error_exit
	.cfi_def_cfa_offset 16
	movl	$1, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	mutable_function_param  # -- Begin function mutable_function_param
	.p2align	4, 0x90
	.type	mutable_function_param,@function
mutable_function_param:                 # @mutable_function_param
	.cfi_startproc
# %bb.0:                                # %entry
	movl	$10, (%rdi)
	retq
.Lfunc_end1:
	.size	mutable_function_param, .Lfunc_end1-mutable_function_param
	.cfi_endproc
                                        # -- End function
	.globl	test_mutable_param      # -- Begin function test_mutable_param
	.p2align	4, 0x90
	.type	test_mutable_param,@function
test_mutable_param:                     # @test_mutable_param
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$100, 4(%rsp)
	leaq	4(%rsp), %rdi
	callq	mutable_function_param
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	test_mutable_param, .Lfunc_end2-test_mutable_param
	.cfi_endproc
                                        # -- End function
	.globl	vstrlen                 # -- Begin function vstrlen
	.p2align	4, 0x90
	.type	vstrlen,@function
vstrlen:                                # @vstrlen
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	strlen
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	vstrlen, .Lfunc_end3-vstrlen
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
