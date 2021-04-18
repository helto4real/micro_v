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
	subq	$16, %rsp
	movabsq	$jmp_buf, %rdi
	callq	setjmp
	cmpq	$0, %rax
	jne	.LBB0_4
# %bb.1:                                # %continue
	movq	%rsp, %rax
	addq	$-16, %rax
	movq	%rax, %rsp
	movl	$100, (%rax)
	movq	%rax, %rdi
	movq	%rax, -8(%rbp)          # 8-byte Spill
	callq	mutable_function_param_with_assert
	movq	-8(%rbp), %rax          # 8-byte Reload
	cmpl	$10, (%rax)
	je	.LBB0_3
# %bb.2:                                # %assert
	movabsq	$.L__unnamed_1, %rdi
	movabsq	$.L__unnamed_2, %rsi
	movb	$0, %al
	callq	printf
	movabsq	$jmp_buf, %rdi
	movl	$1, %esi
	movl	%eax, -12(%rbp)         # 4-byte Spill
	callq	longjmp
.LBB0_3:                                # %assert_cont
	xorl	%eax, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB0_4:                                # %error_exit
	.cfi_def_cfa %rbp, 16
	movl	$1, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	no_mut_or_ref           # -- Begin function no_mut_or_ref
	.p2align	4, 0x90
	.type	no_mut_or_ref,@function
no_mut_or_ref:                          # @no_mut_or_ref
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%edi, 4(%rsp)
	cmpl	$10, 4(%rsp)
	je	.LBB1_2
# %bb.1:                                # %assert
	movabsq	$.L__unnamed_1, %rdi
	movabsq	$.L__unnamed_3, %rsi
	movb	$0, %al
	callq	printf
	movabsq	$jmp_buf, %rdi
	movl	$1, %esi
	movl	%eax, (%rsp)            # 4-byte Spill
	callq	longjmp
.LBB1_2:                                # %assert_cont
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	no_mut_or_ref, .Lfunc_end1-no_mut_or_ref
	.cfi_endproc
                                        # -- End function
	.globl	mutable_function_param_with_assert # -- Begin function mutable_function_param_with_assert
	.p2align	4, 0x90
	.type	mutable_function_param_with_assert,@function
mutable_function_param_with_assert:     # @mutable_function_param_with_assert
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	(%rdi), %edi
	callq	no_mut_or_ref
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	mutable_function_param_with_assert, .Lfunc_end2-mutable_function_param_with_assert
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

	.type	.L__unnamed_2,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_2:
	.asciz	"samples/hello/hello_world.v:16:2: \033[31merror: \033[39massert error\n 15 |   mutable_function_param_with_assert(mut x)\n 16 |   \033[31massert x == 10\033[39m\n    | \033[31m  ~~~~~~~~~~~~~~\033[39m\n 17 | }\n\n\n"
	.size	.L__unnamed_2, 191

	.type	.L__unnamed_1,@object   # @1
.L__unnamed_1:
	.asciz	"%s\n"
	.size	.L__unnamed_1, 4

	.type	.L__unnamed_3,@object   # @2
.L__unnamed_3:
	.asciz	"samples/hello/hello_world.v:6:2: \033[31merror: \033[39massert error\n 5 | fn no_mut_or_ref(x int) {\n 6 |   \033[31massert x == 10\033[39m\n   | \033[31m  ~~~~~~~~~~~~~~\033[39m\n 7 | }\n\n\n"
	.size	.L__unnamed_3, 168

	.section	".note.GNU-stack","",@progbits
