# File:		add_ascii_numbers.asm
# Author:	K. Reek
# Contributors:	P. White, W. Carithers
#		Stephen Allan
#
# Updates:
#		3/2004	M. Reek, named constants
#		10/2007 W. Carithers, alignment
#		09/2009 W. Carithers, separate assembly
#
# Description:	Add two ASCII numbers and store the result in ASCII.
#
# Arguments:	a0: address of parameter block.  The block consists of
#		four words that contain (in this order):
#
#			address of first input string
#			address of second input string
#			address where result should be stored
#			length of the strings and result buffer
#
#		(There is actually other data after this in the
#		parameter block, but it is not relevant to this routine.)
#
# Returns:	The result of the addition, in the buffer specified by
#		the parameter block.
#

	.globl	add_ascii_numbers

add_ascii_numbers:
A_FRAMESIZE = 40

#
# Save registers ra and s0 - s7 on the stack.
#
	addi 	$sp, $sp, -A_FRAMESIZE
	sw 	$ra, -4+A_FRAMESIZE($sp)
	sw 	$s7, 28($sp)
	sw 	$s6, 24($sp)
	sw 	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw 	$s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
# ##### BEGIN STUDENT CODE BLOCK 1 #####

	lw	$t0, 0($a0)		# Load address of first operand
	lw	$t1, 4($a0)		# Load address of second operand
	lw	$t2, 8($a0)		# Load address of return
	lw	$t3, 12($a0)		# Load operand length
	move 	$s3, $zero 		# Set carry to false

	addi 	$t3, $t3, -1 		# Get 0-based length

	add 	$t0, $t0, $t3 		# Advance
	add 	$t1, $t1, $t3		# operand
	add 	$t2, $t2, $t3 		# pointers

add_loop:
	lb	$s0, 0($t0)		# Get first operand
	lb	$s1, 0($t1)		# Get second operand

	add 	$s2, $s0, $s1		# Add first and second operands
	addi	$s2, $s2, -48		# Make ascii

	bne 	$s3, $zero, add_carry	# Check if there is a carry from
					# the last operation
	j 	check_for_carry		# No pervious carry

add_carry:
	addi 	$s2, $s2, 1 		# Add the carry of one
	move 	$s3, $zero 		# Set carry back to false

check_for_carry:
	li 	$t9, 57
	slt 	$t4, $t9, $s2		# Check if sum is > 9
	bne 	$t4, $zero, handle_carry

	j 	advance 		# No carry

handle_carry:
	addi 	$s2, $s2, -10 		# Subtract to get second digit of sum
	li 	$s3, 1 			# Set carry to true

advance:
	sb	$s2, 0($t2)		# Save the digit to the result

	beq	$t3, $zero, loop_done 	# Check if all numbers were added

	addi 	$t0, $t0, -1 		# Advance
	addi 	$t1, $t1, -1 		# operand
	addi 	$t2, $t2, -1 		# pointers
	addi 	$t3, $t3, -1 		# Decrement loop counter

	j 	add_loop

loop_done:

# ###### END STUDENT CODE BLOCK 1 ######

#
# Restore registers ra and s0 - s7 from the stack.
#
	lw 	$ra, -4+A_FRAMESIZE($sp)
	lw 	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw 	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, A_FRAMESIZE

	jr	$ra			# Return to the caller.
