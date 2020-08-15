#
#   cal: a program to print a little calendar given a date
#
#   Copyright (c) 2020, Al Stone <ahs3@ahs3.net>
#
#   This file is part of the RISC-V assembler program cal.
#
#   cal is free software: you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation, either version 2 of the License, or (at your
#   option) any later version.
#
#   Cal is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
#   License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with cal.  If not, see <https://www.gnu.org/licenses/>.
#
	.file	"cal.s"
	.option	pic
	.text
#
# --- data ---------------------------------------------------
	.section	.rodata
	.align	3

ARGS:	.string "month/year: %d/%d\n"
NARGS:	.string "? %d is not enough arguments\n"
NINT_MONTH:	.string "? not an integer month: %s\n"
NINT_YEAR:	.string "? not an integer year: %s\n"

# --- functions ----------------------------------------------
	.text
	.align	1
#
#	convert a string
#
	.global	atoi
	.type	atoi, @function

	addi	sp,sp,-48		# function prologue
	sd	ra,40(sp)
	sd	s0,32(sp)

	li	s2,0x30			# char '0'
	li	s3,0			# char count
	li	s4,10			# base 10
	li	s5,0			# result

	mv	a5,a0
ATOI_LOOP:
	ld	a7,0(a5)
	beq	a7,x0,ATOI_SET		# at '\0', end of string
	sub	a7,a7,s2
	blt	a7,x0,ATOI_EXIT		# less than '0'?
	li	a6,9
	bgt	a7,a6,ATOI_EXIT		# greater than 9?
	mul	s5,s5,s4		# we have another digit, mul x 10
	add	s5,s5,a7		# add in the new digit
	addi	s3,s3,1			# count the digit
	addi	a5,a5,8			# next char
	j	ATOI_LOOP

ATOI_SET:
	mv	a0,s5
	mv	a1,s3

ATOI_EXIT:
	ld	ra,40(sp)		# function epilogue
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra

#
#	main program
#
	.global	main
	.type	main, @function
main:
	addi	sp,sp,-48		# function prologue
	sd	ra,40(sp)
	sd	s0,32(sp)

#
#	right number of args?
#
	li	t0,3
	blt	a0,t0,ERR_NARGS
#
	addi	s0,sp,48
	sd	a0,-40(s0)		# save argc
	sd	a1,-48(s0)		# save &argv
#
# 	first arg is the month number
#
	ld	a5,-48(s0)		# load &argv
	ld	a5,8(a5)		# load &argv[1]
	mv	a0,a5
	call	atoi
	blt	a0,x0,ERR_NINT_MONTH
	sd	a0,-32(s0)
#
#	second arg is the year number
#
	ld	a5,-48(s0)		# load &argv
	ld	a5,16(a5)		# load &argv[2]
	mv	a0,a5
	call	atoi
	blt	a0,x0,ERR_NINT_YEAR
	sd	a0,-24(s0)
#
#	now we know what we need to look up
#
	ld	a2,-24(s0)
	ld	a1,-32(s0)
	lla	a0,ARGS
	call	printf@plt
	j	EXIT
#
#	not an integer month
#
ERR_NINT_MONTH:
	ld	a5,-48(s0)		# load &argv
	ld	a5,8(a5)		# load &argv[1]
	mv	a1,a5
	lla	a0,NINT_MONTH
	call	printf@plt
	j	EXIT

#
#	not an integer year
#
ERR_NINT_YEAR:
	ld	a5,-48(s0)		# load &argv
	ld	a5,16(a5)		# load &argv[2]
	mv	a1,a5
	lla	a0,NINT_YEAR
	call	printf@plt
	j	EXIT

#
#	not enough arguments
#	
ERR_NARGS:
	mv	a1,a0
	addi	a1,a1,-1
	lla	a0,NARGS
	call	printf@plt
	j	EXIT
#
#	all done
#
EXIT:
	li	a0,42			# function return value
	ld	ra,40(sp)		# function epilogue
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
#
#	program end
#
	.size	main, .-main
	.ident	"ahs3"
