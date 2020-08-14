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
