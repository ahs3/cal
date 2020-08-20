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
	.section .rodata
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
DBG:		.string "[%d] %d\n"

DOWS:		.string "sun","mon","tue","wed","thu","fri","sat"
MONS:		.string "Jan","Feb","Mar","Apr","May","Jun"
MONS2:		.string "Jul","Aug","Sep","Oct","Nov","Dec"
MDAYS:		.byte	31,28,31,30,31,30,31,31,30,31,30,31

MONHDR:		.string "      %3s %s\n"
WKHDR:		.string "Su Mo Tu We Th Fr Sa\n"
BUFOUT:		.string "%22s\n"
BUFLEN:		.byte	22
BLANK:		.byte	' '
SPACES:		.string "   "
NUMS:		.string "%2d "
EOL:		.string "\n"

	.bss
	.align	4

BUF:		.quad	0,0,0

# --- functions -----------------------------------------------------
	.text
	.align	1
#--------------------------------------------------------------------
#
#	convert a string
#
	.global	atoi
	.type	atoi, @function
atoi:
	addi	sp,sp,-48		# function prologue
	sd	ra,40(sp)
	sd	s0,32(sp)
	addi	s0,sp,48

	sd	a0,-24(s0)		# save the string address
	li	s2,0x30			# char '0'
	li	s3,0			# char count
	li	s4,10			# base 10
	li	s5,0			# result
	li	s6,9			# digit 9

	ld	s1,-24(s0)
ATOI_LOOP:
	lb	s7,0(s1)
	beq	s7,x0,ATOI_SET		# at '\0', end of string
	sub	s7,s7,s2
	blt	s7,x0,ATOI_EXIT		# less than '0'?
	bgt	s7,s6,ATOI_EXIT		# greater than 9?
	mul	s5,s5,s4		# we have another digit, mul x 10
	add	s5,s5,s7		# add in the new digit
	addi	s3,s3,1			# count the digit
	addi	s1,s1,1			# next char
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
	addi	sp,sp,-80		# function prologue
	sd	ra,72(sp)
	sd	s0,64(sp)
	addi	s0,sp,80
#
	sd	a2,-72(s0)		# save the year
	sd	a1,-64(s0)		# save the day (k)
	sd	a0,-56(s0)		# save the month

# -- DEBUG --------------------------------------
#	ld	a1,-64(s0)		# debug: print k
#	lla	a0,KVAL
#	call	printf@plt
# -- DEBUG --------------------------------------

	ld	a3,-56(s0)		# get the month
	addi	a3,a3,-2		# March is the first month, this time
	bgt	a3,x0,doyear
	addi	a3,a3,12		# so Jan,Feb are 11,12

#
doyear:	
	sd	a3,-48(s0)		# save it for now (adjusted m)

# -- DEBUG --------------------------------------
#	mv	a1,a3			# debug: print m
#	lla	a0,MVAL
#	call	printf@plt
# -- DEBUG --------------------------------------

	ld	a3,-72(s0)		# get the year
	li	a4,0x64
	rem	a3,a3,a4		# mod 100
	ld	a4,-56(s0)		# get the month
	addi	a4,a4,-2		# March is the first month, this time
	bgt	a4,x0,docent
	addi	a3,a3,-1

docent:
	sd	a3,-40(s0)		# save it for now (d)

# -- DEBUG --------------------------------------
#	ld	a1,-40(s0)		# debug: print d
#	lla	a0,DVAL
#	call	printf@plt
# -- DEBUG --------------------------------------

	ld	a3,-72(s0)		# get the year
	li	a4,100
	div	a3,a3,a4		# y / 100 (yes, div)
	sd	a3,-32(s0)		# save it for now (c)

# -- DEBUG --------------------------------------
#	ld	a1,-32(s0)		# debug: print c
#	lla	a0,CVAL
#	call	printf@plt
# -- DEBUG --------------------------------------

#
#	bring it all together
#	dow = k + ((13*m-1) / 5) + d + (d / 4) + (c / 4) - (2 * c)
#
	ld	a7,-64(s0)		# retrieve the day = k
	ld	a5,-48(s0)		# retrieve the adjusted month
	li	a6,0xd
	mul	a5,a5,a6		# m*13
	addi	a5,a5,-1		# (13*m-1)
	li	a6,5
	div	a5,a5,a6		# ((13*m-1) / 5)
	add	a7,a7,a5		# k + ((13*m-1) / 5)
	ld	a5,-40(s0)
	add	a7,a7,a5		# k + ((13*m-1) / 5) + d
	ld	a5,-40(s0)
	srli	a5,a5,2
	add	a7,a7,a5		# k + ((13*m-1)/5) + d + (d/4)
	ld	a5,-32(s0)		# c
	srli	a5,a5,2
	add	a7,a7,a5		# k + ((13*m-1)/5) + d + (d/4) + (c/4)
	ld	a5,-32(s0)		# c
	slli	a5,a5,1
	neg	a5,a5			# -(2*c)
	add	a7,a7,a5		# k+((13*m-1)/5)+d+(d/4)+(c/4)-(2*c)
	blt	a7,x0,dow7a

	li	a6,7
	rem	a7,a7,a6
	j	dwdone

dow7a:	li	a6,-7
	rem	a7,a7,a6
	addi	a7,a7,7
#
dwdone:
	mv	a0,a7
	ld	ra,72(sp)		# function epilogue
	ld	s0,64(sp)
	addi	sp,sp,80
	jr	ra

#--------------------------------------------------------------------
#
#	main program
#
	.global	main
	.type	main, @function
main:
	addi	sp,sp,-80		# function prologue
	sd	ra,72(sp)
	sd	s0,64(sp)
	addi	s0,sp,80
#
#	right number of args?
#

	li	t0,3
	blt	a0,t0,ERR_NARGS
#
	sd	a0,-56(s0)		# save argc
	sd	a1,-48(s0)		# save &argv
#
# 	first arg is the month number
#
	ld	t5,-48(s0)		# load &argv
	ld	t5,8(t5)		# load &argv[1]
	mv	a0,t5
	call	atoi
	blt	a0,x0,ERR_NINT_MONTH
	sd	a0,-40(s0)		# month number
#
#	second arg is the year number
#
	ld	t5,-48(s0)		# load &argv
	ld	t5,16(t5)		# load &argv[2]
	mv	a0,t5
	call	atoi
	blt	a0,x0,ERR_NINT_YEAR
	sd	a0,-32(s0)		# year number
#
#	now we know what we need to look up
#
# -- DEBUG --------------------------------------
#	ld	a2,-32(s0)
#	ld	a1,-40(s0)
#	lla	a0,ARGS
#	call	printf@plt
# -- DEBUG --------------------------------------
#
#	figure out which day of the week the 1st is
#
	ld	a2,-32(s0)		# year is the third arg
	li	a1,1			# always the first of the month
	ld	a0,-40(s0)		# month is the first arg
	call	dow
	sd	a0,-24(s0)		# save the day of week, sun == 0

# -- DEBUG --------------------------------------
#	ld	a2,-24(s0)
#	ld	a6,-24(s0)		# get DOW string address for a1
#	slli	a6,a6,2
#	lla	a7,DOWS
#	add	a1,a7,a6
#	lla	a0,DOW
#	call	printf@plt		# print some debug info
# -- DEBUG --------------------------------------

	ld	t0,-48(s0)		# load &argv
	ld	t0,16(t0)		# load &argv[2]
	mv	a2,t0			# ptr to year string
	lla	t0,MONS
	ld	t1,-40(s0)
	addi	t1,t1,-1
	slli	t1,t1,2
	add	a1,t0,t1		# month string
	lla	a0,MONHDR
	call	printf@plt

	lla	a0,WKHDR
	call	printf@plt
	
	ld	t0,-24(s0)
mloop0:
	ble	t0,x0,mloop1
	lla	a0,SPACES
	call	printf@plt
	addi	t0,t0,-1
	j	mloop0

mloop1:
	li	s2,1
	mv	a1,s2
	lla	a0,NUMS
	call	printf@plt		

	li	a5,7			# days per week

	ld	t0,-40(s0)
	addi	t0,t0,-1
	lla	t1,MDAYS
	add	t0,t0,t1
	lb	s6,0(t0)		# number of days in month
	ld	t0,-40(s0)		# but is it a leap year?
	addi	t0,t0,-2
	bne	t0,x0,nlyear
	ld	t0,-32(s0)		# divisible by 4?
	li	t1,4
	rem	t0,t0,t1
	bne	t0,x0,nlyear
	ld	t0,-32(s0)		# divisible by 100?
	li	t1,0x64
	rem	t0,t0,t1
	bne	t0,x0,lyear
	ld	t0,-32(s0)		# divisible by 400?
	li	t1,0x190
	rem	t0,t0,t1
	beq	t0,x0,nlyear
lyear:
	addi	s6,s6,1			# feb in leap year

nlyear:
	li	a4,1			# day-of-month counter
	sd	a4,-32(s0)		# re-use the space for numeric year

mloop2:
	ld	a4,-32(s0)		# day-of-month counter
	addi	a4,a4,1
	sd	a4,-32(s0)
	bgt	a4,s6,mloop5
	ld	a3,-24(s0)		# day-of-week counter
	addi	a3,a3,1
	sd	a3,-24(s0)
	li	a5,7
	rem	a3,a3,a5
	beq	a3,x0,mloop4
mloop3:
	ld	a1,-32(s0)
	lla	a0,NUMS
	call	printf@plt		
	j	mloop2

mloop4:
	lla	a0,EOL
	call	printf@plt		
	j	mloop3

mloop5:
	lla	a0,EOL
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
	ld	ra,72(sp)		# function epilogue
	ld	s0,64(sp)
	addi	sp,sp,80
	jr	ra
#
#	program end
#
	.size	main, .-main
	.ident	"ahs3"
