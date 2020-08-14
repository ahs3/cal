	.file	"hello2.c"
	.option pic
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"world"
	.text
	.align	1
	.globl	foo
	.type	foo, @function
foo:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	mv	a5,a0
	sw	a5,-20(s0)
	lla	a0,.LC0
	call	puts@plt
	lw	a5,-20(s0)
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	foo, .-foo
	.section	.rodata
	.align	3
.LC1:
	.string	"hello"
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
	lla	a0,.LC1
	call	puts@plt
	li	a5,42
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	call	foo
	li	a5,0
	mv	a0,a5
	ld	ra,40(sp)
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (Debian 8.3.0-4) 8.3.0"
