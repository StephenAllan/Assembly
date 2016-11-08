# File:		build.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		Stephen Allan
#
# Description:	Binary tree building functions.
#
# Revisions:	$Log$


	.text			# this is program code
	.align 2		# instructions must be on word boundaries

# 
# Name:		add_elements
#
# Description:	loops through array of numbers, adding each (in order)
#		to the tree
#
# Arguments:	a0 the address of the array
#   		a1 the number of elements in the array
#		a2 the address of the root pointer
# Returns:	none
#

	.globl	add_elements
	
add_elements:
	addi 	$sp, $sp, -16
	sw 	$ra, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)

#***** BEGIN STUDENT CODE BLOCK 1 ***************************
#
# Insert your code to iterate through the array, calling build_tree
# for each value in the array.  Remember that build_tree requires
# two parameters:  the address of the variable which contains the
# root pointer for the tree, and the number to be inserted.
#
	move 	$s0, $a0 		# Copy a0
	move	$s1, $a1		# Copy a1
	move	$s2, $a2		# Copy a2

add_loop:
	beq	$s1, $zero, add_done 	# If no more elements, jump to done

	move 	$a0, $s2
	lw	$a1, 0($s0)		# Load node value
	jal 	build_tree

	addi 	$s0, $s0, 4		# Update array pointer
	addi 	$s1, $s1, -1 		# Update loop count

	j 	add_loop

#***** END STUDENT CODE BLOCK 1 *****************************

add_done:

	lw 	$ra, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 16
	jr 	$ra

#***** BEGIN STUDENT CODE BLOCK 2 ***************************
#
# Put your build_tree subroutine here.
#
# Name:		build_tree:
#
# Description:	Creates a new node with the given value
#		and adds it to the binary tree
#
# Arguments:	a0: Pointer to root_ptr
#		a1: Value to be added to the tree
# Returns:	none
#
	.globl allocate_mem

build_tree:
	addi 	$sp, $sp, -12
	sw 	$ra, 0($sp)
	sw 	$s0, 4($sp)
	sw 	$s1, 8($sp)

	move 	$s0, $a0 		# Copy a0
	move 	$s1, $a1 		# Copy a1

	li 	$a0, 3 			# Allocate 3 words (size of a node)
	jal 	allocate_mem		# v0 is the new empty node
	sw 	$s1, 0($v0) 		# Save value to new node

	lw	$t0, 0($s0)
	bne 	$t0, $zero, search_tree	# Tree is not empty

	sw 	$v0, 0($s0)		# Tree is empty, store node at root
	j 	build_done

search_tree:
	move	$t1, $v0		# $t1 is the new node
	lw	$t3, 0($t1)		# $t3 is value of new node

build_loop:
					# $t0 is the curr node
	lw	$t2, 0($t0)		# $t2 is value of curr node
	beq	$t2, $t3, build_done	# Discard if values are equal

	slt	$t9, $t3, $t2		# If new < curr
	bne	$t9, $zero, tree_left

	slt	$t9, $t2, $t3		# If new > curr
	bne	$t9, $zero, tree_right

	j 	build_done

tree_left:
	lw	$t9, 4($t0)
	bne 	$t9, $zero, left_not_empty

	sw	$t1, 4($t0)
	j 	build_done

left_not_empty:
	move	$t0, $t9
	j 	build_loop

tree_right:
	lw	$t9, 8($t0)
	bne 	$t9, $zero, right_not_empty

	sw	$t1, 8($t0)
	j 	build_done

right_not_empty:
	move	$t0, $t9
	j 	build_loop

build_done:
	lw 	$s1, 8($sp)
	lw 	$s0, 4($sp)
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, 12
	jr 	$ra

#***** END STUDENT CODE BLOCK 2 *****************************