	.file	"main2.c"
	.option pic
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"count: %ld, value: %s\n"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	ra,40(sp)
	sd	s0,32(sp)
	addi	s0,sp,48
	mv	a5,a0
	sd	a1,-48(s0)
	sw	a5,-36(s0)
	lw	a5,-36(s0)
	sd	a5,-24(s0)
	ld	a5,-48(s0)
	ld	a5,8(a5)
	sd	a5,-32(s0)
	ld	a2,-32(s0)
	ld	a1,-24(s0)
	lla	a0,.LC0
	call	printf@plt
	li	a5,0
	mv	a0,a5
	ld	ra,40(sp)
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (Debian 10.2.0-3) 10.2.0"
	.section	.note.GNU-stack,"",@progbits
