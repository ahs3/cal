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

ARGS:		.string "month/year: %d/%d\n"
DOW:		.string "day of week: %s (%d)\n"
NARGS:		.string "? %d is not enough arguments\n"
NINT_MONTH:	.string "? not an integer month: %s\n"
NINT_YEAR:	.string "? not an integer year: %s\n"

KVAL:		.string "k = %d\n"
MVAL:		.string "m = %d\n"
DVAL:		.string "d = %d\n"
CVAL:		.string "c = %d\n"
DBGDOW:		.string "[%d]%d "
DBGEND:		.string "\n"

DOW0:		.string "sun"
DOW1:		.string "mon"
DOW2:		.string "tue"
DOW3:		.string "wed"
DOW4:		.string "thu"
DOW5:		.string "fri"
DOW6:		.string "sat"

# --- functions -----------------------------------------------------
	.text
	.align	1
#--------------------------------------------------------------------
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
#--------------------------------------------------------------------
#
#	find day of the week via Zeller's Rule
#
	.global	dow
	.type	dow, @function
dow:
	addi	sp,sp,-48		# function prologue
	sd	ra,40(sp)
	sd	s0,32(sp)
#
	sd	a0,-32(s0)		# save the month
	sd	a1,-40(s0)		# save the day (k)
	sd	a2,-48(s0)		# save the year

	ld	a1,-40(s0)		# debug: print k
	lla	a0,KVAL
	call	printf@plt

	ld	s2,-32(s0)		# get the month
	li	s3,2
	sub	s2,s2,s3		# March is the first month, this time
	bgt	s2,x0,doyear
	addi	s2,s2,12		# so Jan,Feb are 11,12

#
doyear:	
	sd	s2,-32(s0)		# save it for now (m)

	mv	a1,s2			# debug: print m
	lla	a0,MVAL
	call	printf@plt

	ld	s3,-48(s0)		# get the year
	li	s4,100
	rem	s3,s3,s4		# mod 100
	ld	s2,-32(s0)		# get the month
	li	s4,2
	sub	s2,s2,s4		# March is the first month, this time
	bgt	s2,x0,docent
	li	s4,1
	sub	s3,s3,s4

docent:
	sd	s3,-24(s0)		# save it for now (d)

	ld	a1,-24(s0)		# debug: print d
	lla	a0,DVAL
	call	printf@plt

	ld	s4,-48(s0)		# get the year
	li	s5,100
	div	s4,s4,s5		# y / 100 (yes, div)
	sd	s4,-16(s0)		# save it for now (c)

	ld	a1,-16(s0)		# debug: print c
	lla	a0,CVAL
	call	printf@plt

#
#	bring it all together
#	dow = k + ((13*m-1) / 5) + d + (d / 4) + (c / 4) - (2 * c)
#
	ld	s7,-40(s0)		# retrieve the day = k
	ld	s5,-32(s0)		# retrieve the adjusted month
	li	s6,0xd
	mul	s5,s5,s6		# m*13
	li	s6,1
	neg	s6,s6
	add	s5,s5,s6		# (13*m-1)
	li	s6,5
	div	s5,s5,s6		# ((13*m-1) / 5)
	add	s7,s7,s5		# k + ((13*m-1) / 5)
	ld	s5,-24(s0)
	add	s7,s7,s5		# k + ((13*m-1) / 5) + d
	ld	s5,-24(s0)
	srli	s5,s5,2
	add	s7,s7,s5		# k + ((13*m-1)/5) + d + (d/4)
	ld	s5,-16(s0)		# c
	srli	s5,s5,2
	add	s7,s7,s5		# k + ((13*m-1)/5) + d + (d/4) + (c/4)
	ld	s5,-16(s0)		# c
	slli	s5,s5,1
	neg	s5,s5			# -(2*c)
	add	s7,s7,s5		# k+((13*m-1)/5)+d+(d/4)+(c/4)-(2*c)
	blt	s7,x0,dow7a

	li	s6,7
	rem	s7,s7,s6
	j	dwdone

dow7a:	li	s6,-7
	rem	s7,s7,s7
	addi	s7,s7,7
#
dwdone:	mv	a0,s7
	ld	ra,40(sp)		# function epilogue
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
#--------------------------------------------------------------------
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
#
#	figure out which day of the week the 1st is
#
	ld	a0,-32(s0)		# month is the first arg
	li	a1,1			# always the first of the month
	ld	a2,-24(s0)		# year is the third arg
	call	dow
	sd	a0,-16(s0)		# save the day of week, sun == 0

	ld	a2,-16(s0)
	ld	a6,-16(s0)		# get DOW string address for a1
	slli	a6,a6,2
	lla	a7,DOW0
	add	a1,a7,a6
	lla	a0,DOW
	call	printf@plt		# print some debug info

	lla	a0,BUF
	call	printf@plt		

	j	EXIT			# all done
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
