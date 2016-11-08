# File:		traverse_tree.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		Stephen Allan
#
# Description:	Binary tree traversal functions.
#
# Revisions:	$Log$


# CONSTANTS
#

# traversal codes
PRE_ORDER  = 0
IN_ORDER   = 1
POST_ORDER = 2

	.text			# this is program code
	.align 2		# instructions must be on word boundaries

#***** BEGIN STUDENT CODE BLOCK 3 *****************************
#
# Put your traverse_tree subroutine here.
#
# Name:         traverse_tree:
#
# Description:  Preform pre-, in-, or post-order traversals on a binary tree.
#
# Arguments:    a0: Pointer to the root of the tree
#               a1: The function to print out a node's value
#               a2: The type of traversal to preform
# Returns:      none
#
	.globl	traverse_tree

traverse_tree:
        beq     $a0, $zero, return              # If value is null, return

        addi    $sp, $sp, -12                   ##
        sw      $ra, 0($sp)                     # Save values
        sw      $a0, 4($sp)                     # to the stack
        sw      $s0, 8($sp)                     ##

        move    $s0, $a0

        li      $t0, PRE_ORDER
        beq     $t0, $a2, pre_order             # Branch to pre-order traversal
        
        li      $t0, IN_ORDER
        beq     $t0, $a2, in_order              # Branch to in-order traversal

        li      $t0, POST_ORDER
        beq     $t0, $a2, post_order            # Branch to post-order traversal

        j       done_traversal

# Preforms a recursive pre-order traversal
pre_order:
        jalr    $a1                             # Print value

        lw      $a0, 4($s0)
        jal     traverse_tree                   # Recurse with left node

        lw      $a0, 8($s0)
        jal     traverse_tree                   # Recurse with right node

        j       done_traversal

# Preforms a recursive in-order traversal
in_order:
        lw      $a0, 4($s0)
        jal     traverse_tree                   # Recurse with left node

        move    $a0, $s0
        jalr    $a1                             # Print value

        lw      $a0, 8($s0)
        jal     traverse_tree                   # Recurse with right node

        j       done_traversal

# Preforms a recursive post-order traversal
post_order:
        lw      $a0, 4($s0)
        jal     traverse_tree                   # Recurse with left node

        lw      $a0, 8($s0)
        jal     traverse_tree                   # Recurse with right node

        move    $a0, $s0
        jalr    $a1                             # Print value

        j       done_traversal

done_traversal:
        lw      $s0, 8($sp)                     ##
        lw      $a0, 4($sp)                     # Restore values
        lw      $ra, 0($sp)                     # from the stack
        addi    $sp, $sp, 12                    ##

return:
        jr      $ra

#***** END STUDENT CODE BLOCK 3 *****************************