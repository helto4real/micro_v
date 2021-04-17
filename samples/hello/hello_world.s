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
	je	.LBB0_3
	jmp	.LBB0_4
.LBB0_1:                                # %assert_cont
	movabsq	$sprintf_buff, %rdi
	movabsq	$.L__unnamed_1, %rsi
	movl	$1, %edx
	movb	$0, %al
	callq	sprintf
	movabsq	$.L__unnamed_2, %rdi
	movabsq	$sprintf_buff, %rsi
	movl	%eax, -4(%rbp)          # 4-byte Spill
	movb	$0, %al
	callq	printf
	xorl	%ecx, %ecx
	movl	%eax, -8(%rbp)          # 4-byte Spill
	movl	%ecx, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB0_2:                                # %assert
	.cfi_def_cfa %rbp, 16
	movabsq	$.L__unnamed_2, %rdi
	movabsq	$.L__unnamed_3, %rsi
	movb	$0, %al
	callq	printf
	movabsq	$jmp_buf, %rdi
	movl	$1, %esi
	movl	%eax, -12(%rbp)         # 4-byte Spill
	callq	longjmp
.LBB0_3:                                # %continue
	movq	%rsp, %rax
	addq	$-16, %rax
	movq	%rax, %rsp
	movl	$1, (%rax)
	cmpl	$1, (%rax)
	je	.LBB0_1
	jmp	.LBB0_2
.LBB0_4:                                # %error_exit
	movl	$1, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
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

	.type	.L__unnamed_3,@object   # @0
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__unnamed_3:
	.asciz	"samples/hello/hello_world.v:3:2: \033[31merror: \033[39massert error\n 2 |   a := 1\n 3 |   \033[31massert a == 1\033[39m\n   | \033[31m  ~~~~~~~~~~~~~\033[39m\n 4 |   println(string(1))\n\n\n"
	.size	.L__unnamed_3, 168

	.type	.L__unnamed_2,@object   # @1
.L__unnamed_2:
	.asciz	"%s\n"
	.size	.L__unnamed_2, 4

	.type	.L__unnamed_1,@object   # @2
.L__unnamed_1:
	.asciz	"%d"
	.size	.L__unnamed_1, 3

	.section	".note.GNU-stack","",@progbits
