# File:         life_age.asm
# Author:       Stephen Allan [swa9846]
# Section:      01
#
# Description:  MIPS Simulator for Conway's Game of Life. Prompts the user for
#               input, validates input, builds the starting board, and runs the
#               specified number of generations following the rules of Conway's
#               Game of Life.
#
#               Reads in the size of the board, the number of generations to
#               run, the number of alive cells on the starting board as well as
#               their locations.
#
#               Program outputs the game's header, the first generation's title
#               and board, and any subsequent generation's title and board
#               updated according to the previous generation's board and the
#               rules of the game of life.
#


# CONSTANTS
#
MAX_SIZE =      30
START_ALPHA =   65
SPACE_ALPHA =   32
# syscall codes
PRINT_INT =     1
PRINT_STRING =  4
READ_INT =      5
EXIT =          10
PRINT_CHAR =    11


# Data Block
        .data
        .align  2

board_A:
        .space	( (MAX_SIZE * MAX_SIZE) + MAX_SIZE ) * 4
board_B:
        .space  ( (MAX_SIZE * MAX_SIZE) + MAX_SIZE ) * 4
size:
        .word   0
generations:
        .word   0
alive:
        .word   0

banner_star:
        .asciiz "\n*************************************\n"
banner_title:
        .asciiz "****    Game of Life with Age    ****"
endl:
        .asciiz "\n"
input_size:
        .asciiz "\nEnter board size: "
input_gen:
        .asciiz "\nEnter number of generations to run: "
input_alive:
        .asciiz "\nEnter number of live cells: "        
input_loc:
        .asciiz "\nStart entering locations\n"
illegal_size:
        .asciiz "\nWARNING: illegal board size, try again: "
illegal_gen:
        .asciiz "\nWARNING: illegal number of generations, try again: "
illegal_alive:
        .asciiz "\nWARNING: illegal number of live cells, try again: "
illegal_loc:
        .asciiz "\nERROR: illegal point location\n"
gen_open:
        .asciiz "\n====    GENERATION "
gen_close:
        .asciiz "    ====\n"
board_plus:
        .asciiz "+"
board_minus:
        .asciiz "-"
board_side:
        .asciiz "|"


# Text Block
        .text
        .align  2

        .globl main

#
# Name:         main
#
# Description:  Main program which manages and calls all sub routines needed to
#               play the game of life.
#
main:
        addi    $sp, $sp, -36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)

        # Print banner
        li      $v0, PRINT_STRING
        la      $a0, banner_star
        syscall
        la      $a0, banner_title
        syscall
        la      $a0, banner_star
        syscall


        jal     get_input               # Ask user for input

        jal     B_to_A                  # Copy board_B to board_A for printing

        move    $s1, $zero              # s1 is the current generation

        # Print generation 0 title
        li      $v0, PRINT_STRING
        la      $a0, gen_open
        syscall

        li      $v0, PRINT_INT
        move    $a0, $s1
        syscall

        li      $v0, PRINT_STRING
        la      $a0, gen_close
        syscall

        jal     print_board


# Generations 1 - n
        la      $t0, generations
        lw      $s0, 0($t0)             # s0 is the total number of generations
        
        la      $t0, size
        lw      $s7, 0($t0)             # t0 is size
        addi    $s6, $s7, -1            # s6 is size-1

generation_loop:
        beq     $s1, $s0, done
        addi    $s1, $s1, 1

        move    $s2, $zero              # s2 is the current offset
        move    $s3, $zero              # col
        move    $s4, $zero              # row
        mul     $s5, $s7, $s7           # s5 is count = size*size

build_next_gen:
        beq     $s5, $zero, gen_done
        addi    $s5, $s5, -1

        move    $a0, $s2
        move    $a1, $s3
        move    $a2, $s4
        jal     find_neighbors          # v0 is the number of neighbors
        move    $a2, $v0

        la      $t0, board_A
        add     $t0, $t0, $s2
        lw      $a1, 0($t0)

        move    $a0, $s2
        jal     gol_rules


        addi    $s2, $s2, 4             # look at next cell

        slt     $t0, $s3, $s6
        beq     $t0, $zero, inc_row

        addi    $s3, $s3, 1             # increment col
        j       build_next_gen

inc_row:
        move    $s3, $zero
        addi    $s4, $s4, 1             # increment row
        j       build_next_gen


gen_done:
        jal     B_to_A                  # Copy board_B to board_A for printing

        # Print generation
        li      $v0, PRINT_STRING
        la      $a0, gen_open
        syscall

        li      $v0, PRINT_INT
        move    $a0, $s1
        syscall

        li      $v0, PRINT_STRING
        la      $a0, gen_close
        syscall

        jal     print_board

        j       generation_loop


done:
        lw      $s7, 32($sp)
        lw      $s6, 28($sp)
        lw      $s5, 24($sp)
        lw      $s4, 20($sp)
        lw      $s3, 16($sp)
        lw      $s2, 12($sp)
        lw      $s1, 8($sp)
        lw      $s0, 4($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 36

        li      $v0, EXIT
        syscall



#
# Name:         get_input
#
# Description:  Prompts user for input of board size, number of generations,
#               number of alive cells, and their locations. Validates all input,
#               printing warnings for incorrect values and terminating on
#               location failure.
#
# Arguments:    none
#
# Returns:      none
#
get_input:
        addi    $sp, $sp, -8
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)


        # Input board size
        li      $v0, PRINT_STRING
        la      $a0, input_size
        syscall

prompt_size:
        li      $v0, READ_INT
        syscall
        
        bne     $v1, $zero, size_error  # Validate input
        slti    $t0, $v0, 4
        bne     $t0, $zero, size_error
        slti    $t0, $v0, 31            # Input is > 3
        beq     $t0, $zero, size_error
                                        # Input is > 3 and < 31
	mul	$t9, $v0, $v0		# Number of cells on the board
	addi	$t9, $t9, 1

        la      $t0, size
        sw      $v0, 0($t0)

        jal     zero_out


        # Input generations
        li      $v0, PRINT_STRING
        la      $a0, input_gen
        syscall

prompt_gen:
        li      $v0, READ_INT
        syscall

        bne     $v1, $zero, gen_error   # Validate input
        slti    $t0, $v0, 0
        bne     $t0, $zero, gen_error
        slti    $t0, $v0, 21            # Input is > -1
        beq     $t0, $zero, gen_error
        				# Input is > -1 and < 21
	la      $t0, generations
        sw      $v0, 0($t0)


        # Input alive cells
        li      $v0, PRINT_STRING
        la      $a0, input_alive
        syscall

prompt_alive:
        li      $v0, READ_INT
        syscall

        bne     $v1, $zero, alive_error # Validate input
	slti    $t0, $v0, 0             
        bne     $t0, $zero, alive_error
        slt     $t0, $v0, $t9           # Input is > -1
        beq     $t0, $zero, alive_error
        				# Input is > -1 and < numCells
        la      $t0, alive
        move    $s0, $v0
        sw      $v0, 0($t0)


        # Input locations
        beq     $s0, $zero, finish_input
        li      $v0, PRINT_STRING
        la      $a0, input_loc
        syscall

prompt_loc:
        beq     $s0, $zero, finish_input

        li      $v0, READ_INT
        syscall
        move    $t2, $v0
        move    $t9, $v1

        li      $v0, READ_INT
        syscall
        move    $t3, $v0

        la      $t0, size
        lw      $t4, 0($t0)

        bne     $t9, $zero, loc_error   # Validate row input
        slti    $t0, $t2, 0
        bne     $t0, $zero, loc_error
                                        # Input is > -1
        slt     $t0, $t2, $t4
        beq     $t0, $zero, loc_error
                                        # Input is > -1 and < size

        bne     $v1, $zero, loc_error   # Validate col input
        slti    $t0, $t3, 0
        bne     $t0, $zero, loc_error
                                        # Input is > -1
        slt     $t0, $t3, $t4
        beq     $t0, $zero, loc_error
                                        # Input is > -1 and < size

        move    $a0, $t2
        move    $a1, $t3
        
        jal     add_alive
        bne     $v0, $zero, loc_error

        addi    $s0, $s0, -1
        j       prompt_loc


size_error:
        li      $v0, PRINT_STRING
        la      $a0, illegal_size
        syscall
        j       prompt_size

gen_error:
        li      $v0, PRINT_STRING
        la      $a0, illegal_gen
        syscall
        j       prompt_gen

alive_error:
        li      $v0, PRINT_STRING
        la      $a0, illegal_alive
        syscall
        j       prompt_alive

loc_error:
        li      $v0, PRINT_STRING
        la      $a0, illegal_loc
        syscall

        li      $v0, EXIT
        syscall

finish_input:
        lw      $s0, 4($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 8

        jr      $ra



#
# Name:         zero_out
#
# Description:  Fill the entire board_B with spaces [ascii value of 32].
#
# Arguments:    none
#
# Returns:      none
#
zero_out:
        la      $t3, board_B

        la      $t0, size
        lw      $t0, 0($t0)             # t0 is size              
        mul     $t0, $t0, $t0           # t0 is count = size*size

zero_loop:
        beq     $t0, $zero, zero_done

        li      $t1, SPACE_ALPHA
        sw      $t1, 0($t3)

        addi    $t3, $t3, 4

        addi    $t0, $t0, -1
        j       zero_loop

zero_done:
        jr      $ra



#
# Name:         add_alive
#
# Description:  Adds an alive cell to board_B at the specified row and column.
#
# Arguments:    a0 - row
#               a1 - column
#
# Returns:      v0 - 1 if already alive, 0 otherwise
#
add_alive:
        la      $t0, size
        lw      $t0, 0($t0)             # t0 is size

        li      $t9, 4
        mul     $t1, $t0, $t9           # size*4
        mul     $t1, $t1, $a0           # (size*4)*row

        mul     $t2, $a1, $t9           # col*4
        add     $t1, $t1, $t2           # (size*4)*row + col*4
                                        # t1 has the offset
        la      $t3, board_B
        add     $t3, $t3, $t1

        lw      $t2, 0($t3)

        li      $t4, SPACE_ALPHA
        beq     $t2, $t4, alive_save

        li      $v0, 1
        jr      $ra

alive_save:
        li      $t1, START_ALPHA
        sw      $t1, 0($t3)

        move    $v0, $zero
        jr      $ra



#
# Name:         B_to_A
#
# Description:  copies the values in board B onto board A.
#
# Arguments:    none
#
# Returns:      none
#
B_to_A:
        la      $t2, board_A
        la      $t3, board_B

        la      $t0, size
        lw      $t0, 0($t0)             # t0 is size              
        mul     $t0, $t0, $t0           # t0 is count = size*size

BA_loop:
        beq     $t0, $zero, BA_done

        lw      $t1, 0($t3)
        sw      $t1, 0($t2)

        addi    $t2, $t2, 4
        addi    $t3, $t3, 4

        addi    $t0, $t0, -1
        j       BA_loop

BA_done:
        jr      $ra



#
# Name:         print_board
#
# Description:  Displays the current board_A formatted for a console output.
#
# Arguments:    none
#
# Returns:      none
#
print_board:
        addi    $sp, $sp, -12
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)

        jal     print_board_boundry

        move    $s0, $zero              # col
        move    $s1, $zero              # row
        la      $t2, board_A

        la      $t0, size
        lw      $t0, 0($t0)             # t0 is size

        mul     $t9, $t0, $t0           # t9 is count = size*size
        addi    $t0, $t0, -1            # t0 is size-1

new_row:
        beq     $t9, $zero, print_done
        li      $v0, PRINT_STRING       # Print format
        la      $a0, board_side
        syscall

print_loop:
        beq     $t9, $zero, print_done
        addi    $t9, $t9, -1

        lw      $a0, 0($t2)
        addi    $t2, $t2, 4

        li      $v0, PRINT_CHAR         # Print current value
        syscall


        slt     $t3, $s0, $t0
        beq     $t3, $zero, add_row

        addi    $s0, $s0, 1
        j       print_loop

add_row:
        move    $s0, $zero
        addi    $s1, $s1, 1

        li      $v0, PRINT_STRING       # Print format
        la      $a0, board_side
        syscall
        la      $a0, endl
        syscall

        j       new_row

print_done:
        jal     print_board_boundry

        lw      $s1, 8($sp)
        lw      $s0, 4($sp)
        lw      $ra, 0($sp)
        addi    $sp, $sp, 12

        jr      $ra



#
# Name:         print_board_boundry
#
# Description:  Display the heading/closing printing format of the board.
#
# Arguments:    none
#
# Returns:      none
#
print_board_boundry:
        la      $t0, size
        lw      $t0, 0($t0)             # t0 is size

        li      $v0, PRINT_STRING       # Print format
        la      $a0, board_plus
        syscall

boundry_loop:
        beq     $t0, $zero, boundry_done

        la      $a0, board_minus
        syscall

        addi    $t0, $t0, -1
        j       boundry_loop

boundry_done:
        la      $a0, board_plus
        syscall
        la      $a0, endl
        syscall

        jr      $ra



#
# Name:         find_neighbors
#
# Description:  Finds the number of neighbors for the given cell.
#
# Arguments:    a0 - the offset of the cell in the array
#               a1 - the column of the offset
#               a2 - the row of the offset
#
# Returns:      v0 - the number of neighbors of a0
#
find_neighbors:
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)

        li      $t1, 4
        move    $v0, $zero              # v0 is the number of neighbors
        la      $t4, SPACE_ALPHA

        la      $t3, board_A
        add     $t3, $t3, $a0           # look at the current cell

        la      $t0, size
        lw      $t0, 0($t0)

        mul     $t6, $t0, $t0
        sub     $t6, $t6, $t0           
        mul     $t6, $t6, $t1           # t6 is ((size*size)-size)*4
        addi    $t5, $t0, -1            # t5 is size-1
        mul     $t0, $t0, $t1           # t0 is size*4

# ===== CHECK CASE ===== #
        ## Corners ##
        beq     $a0, $zero, C_tl        # top-left

        mul     $t2, $t5, $t1           # (size-1)*4
        beq     $a0, $t2, C_tr          # top-right

        mul     $t2, $t0, $t5           # (size*4)*(size-1)
        beq     $a0, $t2, C_bl          # bottom-left

        mul     $t9, $t5, $t1           # (size-1)*4
        add     $t2, $t2, $t9           # (size*4)*(size-1) + (size-1)*4
        beq     $a0, $t2, C_br          # bottom-right

        ## Borders ##
        beq     $a1, $t5, C_right       # right

        beq     $a1, $zero, C_left      # left

        beq     $a2, $zero, C_top       # top

        beq     $a2, $t5, C_bottom      # bottom


# ===== MIDDLE CASE ===== #
C_middle:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        addi    $t2, $t2, 4             # Check top neighbor
        jal     check_neighbor

        addi    $t2, $t2, 4             # Check top-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        addi    $t2, $t2, 4             # Check bottom neighbor
        jal     check_neighbor

        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== RIGHT CASE ===== #
C_right:
        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== LEFT CASE ===== #
C_left:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0     
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== TOP CASE ===== #
C_top:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3    
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        addi    $t2, $t2, 4            # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== BOTTOM CASE ===== #
C_bottom:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3    
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== TL CORNER CASE ===== #
C_tl:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0    
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        addi    $t2, $t2, 4            # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== TR CORNER CASE ===== #
C_tr:
        la      $t2, board_A            # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3   
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0           # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t6
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4            # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== BL CORNER CASE ===== #
C_bl:
        move    $t2, $t3
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3
        add     $t2, $t2, $t0    
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        la      $t2, board_A            # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0           # Check top neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6
        addi    $t2, $t2, 4             # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6
        add     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4            # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done

# ===== BR CORNER CASE ===== #
C_br:
        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4             # Check right neighbor
        jal     check_neighbor

        move    $t2, $t3   
        addi    $t2, $t2, -4            # Check left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6            # Check bottom neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0           # Check top neighbor
        jal     check_neighbor

        la      $t2, board_A            # Check bottom-right neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t6
        addi    $t2, $t2, -4            # Check bottom-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        addi    $t2, $t2, -4            # Check top-left neighbor
        jal     check_neighbor

        move    $t2, $t3
        sub     $t2, $t2, $t0
        sub     $t2, $t2, $t0
        addi    $t2, $t2, 4            # Check top-right neighbor
        jal     check_neighbor

        j       neighbors_done


neighbors_done:
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra

check_neighbor:
        lw      $t1, 0($t2)             # look at neighbor
        beq     $t1, $t4, empty
        addi    $v0, $v0, 1             # increment number of neighbors
empty:
        jr      $ra



#
# Name:         gol_rules
#
# Description:  Enforces the standard rules of Conway's game of life. Generates
#               board_B for the next generation based off of these rules and
#               board_A.
#
# Arguments:    a0 - the offset of the cell in the array
#               a1 - the value in board_A at the offset
#               a2 - the number of neighbors the cell has
#
# Returns:      none
#
gol_rules:

        la      $t2, board_B
        add     $t2, $t2, $a0

        la      $t3, START_ALPHA
        la      $t4, SPACE_ALPHA

        beq     $a1, $t4, dead_cell 

alive_cell:
        li      $t0, 1
        slt     $t1, $t0, $a2
        beq     $t1, $zero, kill_cell           # neighbors is > 1

        li      $t0, 4
        slt     $t1, $a2, $t0
        beq     $t1, $zero, kill_cell           # neighbors is < 4

        addi    $t1, $a1, 1
        sw      $t1, 0($t2)
        j       gol_done

kill_cell:
        sw      $t4, 0($t2)
        j       gol_done


dead_cell:
        li      $t0, 3
        bne     $a2, $t0, gol_done

        sw      $t3, 0($t2)


gol_done:
        jr      $ra
