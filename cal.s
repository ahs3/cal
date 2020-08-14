#
#	cal: a program to print a little calendar given a date
#
	.file	"cal.s"
	.option	pic
	.text
	.align	1
	.global	main
	.type	main, @function
#
#	main program
#
main:
	addi	sp,sp,-32		# function prologue
	sd	ra,24(sp)
	sd	s0,16(sp)
#
#	important stuff goes here
#
	li	a0,42			# function return value
	ld	ra,24(sp)		# function epilogue
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
#
#	program end
#
	.size	main, .-main
	.ident	"ahs3"
