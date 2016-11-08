

.data     # start the data segment, which holds all variables

ask_rows:       .asciiz "Enter the number of rows in the Grid:" # First cout statement
ask_cols:       .asciiz "Enter the number of columns in the Grid:" # Second cout statement
for_readi:      .asciiz "Row "
for_readj:      .asciiz " column "
ask_game:       .asciiz "Now pease enter the row and column yo want to inquire about \n"
r_i:            .asciiz "Row: "
c_j:            .asciiz "Column: "
alive_num:      .asciiz "Number of alive neighbours:"
endl:           .asciiz "\n" # newline
aliveee:        .asciiz "The cell is alive"
deaddd:         .asciiz "The cell is Dead"
ask_again:      .asciiz "Wana go again? If yes, enter '1' and if no enter '0'\n"
dead_answer:    .asciiz "The cell is dead in the next generation"
alive_answer:   .asciiz "The cell is alive in the next generation"
play_again:     .asciiz "Go Again? Enter '1' and if no enter '0'\n" 




.align  2 #needed to declare words
array:      .space      400 # enough space for a 20x20 array of words.
num_rows:   .space  4
num_cols:   .space  4
alive:      .space  4




.text          # defines the text segment


.globl main

main:                   # start of the program

go_again: 




# First, output the first propmt
la      $a0, ask_rows
addi    $v0,$zero, 4
syscall

# Next, read the number of rows into $s0
addi    $v0, $zero, 5
syscall
add     $s0, $zero, $v0



####Do the same just for colums now.

# output asking number of columns
la      $a0, ask_cols
addi    $v0,$zero, 4
syscall

# Next, read the number of cols into $s0
addi    $v0, $zero, 5
syscall
add     $s1, $zero, $v0




#####
####
#### for (int i = 0; i < num_rows; i++){
####    for(int j = 0; j < num_columns; j++){
### 
###             cin >> a[i][j]
### }
###}
###
###
###
###



## get num rows and num cols back into registers






#So we have num_rows in $s0, and num_cols in $s1

add $t0, $zero, $zero
add $t1, $zero, $zero
add $s3, $zero, $zero

#$t0 is my i index
#$t1 is my j index


#----------------------------------------------------------------------------------------------------------Step 1
read_grid_i:


        slt $t2, $t0, $s0  ## If $t0 < $s0, then $t2 = 1 Else $t2 = 0
                           ## i < num_rows
        
        beq $t2, $zero, end_read_grid_i #end loop if $t2 = 0

        
        add $t1, $zero, $zero
    

        read_grid_j:
        
        

                slt $t2, $t1, $s1  ## If $t1 < $s1, then $t2 = 1 Else $t2 = 0
                                   ## i < num_cols

                beq $t2, $zero, end_read_grid_j #end loop if $t2 = 0

            


            addi $v0, $zero, 4
            la   $a0, for_readi
            syscall


            addi $v0, $zero, 1
            add  $a0, $t0, $zero
            syscall
        

            addi $v0, $zero, 4
            la   $a0, for_readj
            syscall


            addi $v0, $zero, 1
            add  $a0, $t1, $zero
            syscall

            
            la  $a0, endl
            addi        $v0,$zero, 4
            syscall

            

                
#####do the read in from the user.
        addi $v0, $zero, 12 #read char
        syscall
        add $s2, $zero, $v0





    la  $a0, endl
    addi        $v0,$zero, 4
    syscall



#####now load into the array.
###$s3 for bytes


la $s3, array

mult $t0, $s0 #i * num_rows
mflo $t4

## $s3 = $t0 * $s0 + $t1

add $s4, $t4, $t1

add $s3, $s3, $s4

sb $s2, 0($s3)
    



addi $t1, $t1, 1   #increment column








   #increment bytes



    j read_grid_j
                
    end_read_grid_j:



        addi $t0, $t0, 1 #increment row

        j read_grid_i

end_read_grid_i:

#------------------------------------------------------------------------------------------------------End of Step 1


#store number of rows onto variable
la $a0, num_rows
sw $s0, 0($a0) #num_rows = $s0



#store number of cols onto variable
la $a0, num_cols
sw $s1, 0($a0) #num_cols = $s0








###Now array is loaded with * and -
## now we want to ask use to enter a specific row and colum



la      $a0, ask_game
addi    $v0,$zero, 4
syscall

###row to search
la      $a0, r_i
addi    $v0,$zero, 4
syscall


##get row to search
addi $v0, $zero, 5
syscall


###row to search in $s0
add $s0, $v0, $zero



add $v0, $zero, $zero


##col to search
addi    $v0, $zero, 4
la      $a0, c_j
syscall


##get col to search
addi $v0, $zero, 5
syscall


##col to search in $s1
add $s1, $v0, $zero









##now We have to check ($s0,$s1)
## we have the sizes that our the bounds, num_rows and num_cols.


la $a0, num_rows
lb $s2, 0($a0)



la $a0, num_cols
lb $s3, 0($a0)


#row size is in $s2, col size is in $s3

add $s4, $zero, $zero
#planing on using $s4 for num of alive cells. 


la $a0, array


#--------------------------------------------------------------------------------------------------------Tiny test

##for debug purposes...
mult $s0, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $s1 #$s1 is column he wants to look at. 

la $a0, array
add $a1, $a0, $a1
lb $t2, 0($a1)



addi $t3, $zero, 45
beq $t2, $t3, dead



#say alive if not dead
addi $v0, $zero, 4
la $a0, aliveee
syscall


j End_function


#say dead if asked to jump here. 
dead:

addi $v0, $zero, 4
la $a0, deaddd
syscall

End_function:

#--------------------------------------------------------------------------------------------------------endTinytest


add $v0, $zero, $zero
la $a0, array

jal count_neighbours



add $s4, $v0, $zero

#putting num of alive neibours in $s4







la      $a0, endl
addi    $v0,$zero, 4
syscall




addi $v0, $zero, 4
la $a0, alive_num
syscall





addi $v0, $zero, 1
add $a0, $s4, $zero
syscall






la      $a0, endl
addi    $v0,$zero, 4
syscall



#____________________________________________________________________________________________________________Part_2
#check if cell is alive in the next generation or not. 


##in order to reach a conclusion, the first think I want to know
##if the cell is alive right now or dead.


##



add $t0, $zero, $zero
add $t1, $zero, $zero
add $t2, $zero, $zero
add $t3, $zero, $zero


#subject row is in $s0, subjec col is $s1
#row size is in $s2, col size is in $s3


#$s4 is num of neighbours alive. 




##for debug purposes...
mult $s0, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $s1 #$s1 is column he wants to look at.

la $a0, array
add $a1, $a0, $a1
lb $t2, 0($a1)



addi $t3, $zero, 45
beq $t2, $t3, dead_cell_bracket



    beq $s4, $zero, final_dead ## 0 neighbours, then dead.

    addi $t1, $zero, 1

    
    beq $s4, $t1, final_dead


    add $t1, $zero, $zero


    addi $t1, $zero, 2
    beq  $s4, $t1, final_alive


    add $t1, $zero, $zero


    addi $t1, $zero, 3
    beq  $s4, $t1, final_alive


    
    add $t1, $zero, $zero
    


    slti $t0, $s4, 3        #  if $s4 < 3 then $t0 = 1 else $t0 = 0
    beq $t0, $zero, final_dead






dead_cell_bracket: ###cell is dead

#dead in all cases unless exactly 3 neighbours.



    addi $t1, $zero, 3
    beq  $s4, $t1, final_alive

#else
    j final_dead


final_alive:


addi $v0, $zero, 4
la $a0, alive_answer
syscall

j end_nextGen_test




final_dead:


addi $v0, $zero, 4
la $a0, dead_answer
syscall


j end_nextGen_test









end_nextGen_test:





la      $a0, endl
addi    $v0,$zero, 4
syscall






####ask if they want to go again

addi $v0, $zero, 4
la $a0, play_again
syscall



addi    $v0, $zero, 5
syscall
add     $t3, $zero, $v0



bne $t3, $zero, go_again







addi    $v0,$zero,10
syscall          #system function 10 is "exit program"

####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################








#fucntion to count neighbours
count_neighbours:
#row = $s0
#col = $s1
#row_size= $s2
#col_size= $s3
##there are 8 spots to look at
##say the user wants to look at (row, col)



#spot 1:
####($s0 - 1, $s1 - 1) ie (row - 1, col - 1)
#r_current = $t3, c_current = $t4



add $t3, $zero, $zero
add $t4, $zero, $zero

addi $t3, $s0, -1
addi $t4, $s1, -1

#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a1, $a0
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_2

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_2


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_2



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_2



add $t0, $zero, $zero


addi $t1, $zero, 45
beq $t2, $t1, next_2



#####else it's alive!!!!
addi $v0, $v0, 1


next_2:

#don't need the numebr of people dead so I don't want it to do anything
#just carry on.

add $t2, $zero, $zero #clear it so next position's char can be here



add $t3, $zero, $zero
add $t4, $zero, $zero

#spot 2:
####($s0 - 1, $s1) ie (row - 1, col)
#r_current = $t3, c_current = $t4





addi $t3, $s0, -1
add $t4, $s1, $zero


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_3

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_3


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_3



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_3



add $t0, $zero, $zero



addi $t1, $zero, 45
beq $t2, $t1, next_3



#####else it's alive!!!!
addi $v0, $v0, 1


next_3:






add $t2, $zero, $zero #clear it so next position's char can be here





add $t3, $zero, $zero
add $t4, $zero, $zero



#spot 3:
####($s0 - 1, $s1 + 1) ie (row - 1, col + 1)
#r_current = $t3, c_current = $t4
addi $t3, $s0, -1
addi $t4, $s1, 1


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_4

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_4


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_4



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_4



add $t0, $zero, $zero


addi $t1, $zero, 45
beq $t2, $t1, next_4


#####else it's alive!!!!
addi $v0, $v0, 1


next_4:

add $t2, $zero, $zero #clear it so next position's char can be here




add $t3, $zero, $zero
add $t4, $zero, $zero





#spot 4:
####($s0, $s1 - 1) ie (row, col - 1)
#r_current = $t3, c_current = $t4

add $t3, $s0, $zero
addi $t4, $s1, -1


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_5

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_5


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_5



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_5



add $t0, $zero, $zero



addi $t1, $zero, 45
beq $t2, $t1, next_5


#####else it's alive!!!!
addi $v0, $v0, 1


next_5:




add $t2, $zero, $zero #clear it so next position's char can be here


add $t3, $zero, $zero
add $t4, $zero, $zero




#spot 5
####($s0, $s1 + 1) ie (row, col + 1)
#r_current = $t3, c_current = $t4
add $t3, $s0, $zero
addi $t4, $s1, 1


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_6

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_6


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_6



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_6



add $t0, $zero, $zero


addi $t1, $zero, 45
beq $t2, $t1, next_6


#####else it's alive!!!!
addi $v0, $v0, 1


next_6:




add $t2, $zero, $zero #clear it so next position's char can be here



add $t3, $zero, $zero
add $t4, $zero, $zero


#spot 6
####($s0 + 1, $s1 - 1) ie (row + 1, col - 1)
#r_current = $t3, c_current = $t4
addi $t3, $s0, 1
addi $t4, $s1, -1


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_7

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_7


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_7



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_7


add $t0, $zero, $zero



addi $t1, $zero, 45
beq $t2, $t1, next_7



#####else it's alive!!!!
addi $v0, $v0, 1


next_7:




add $t2, $zero, $zero #clear it so next position's char can be here


add $t3, $zero, $zero
add $t4, $zero, $zero


#spot 7
####($s0 + 1, $s1) ie (row + 1, col)
#r_current = $t3, c_current = $t4
addi $t3, $s0, 1
add $t4, $s1, $zero


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_8

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_8


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, next_8



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, next_8


add $t0, $zero, $zero


addi $t1, $zero, 45
beq $t2, $t1, next_8


#####else it's alive!!!!
addi $v0, $v0, 1


next_8:




add $t2, $zero, $zero #clear it so next position's char can be here


add $t3, $zero, $zero
add $t4, $zero, $zero

#spot 8
####($s0 + 1, $s1 + 1) ie (row + 1, col + 1)
#r_current = $t3, c_current = $t4
addi $t3, $s0, 1
addi $t4, $s1, 1


#set address to check
mult $t3, $s2 #i * num_rows
mflo $t1



add $a1, $t1, $t4
add $a1, $a0, $a1
lb $t2, 0($a1)



slt $t0, $t3, $zero #if $t3 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, done

add $t0, $zero, $zero



slt $t0, $t3, $s2 #if $t3 < $s2, $t0 = 1, else $t0 = 0.
beq $t0, $zero, done


add $t0, $zero, $zero



slt $t0, $t4, $zero #if $t4 < 0, $t0 = 1, else $t0 = 0.
bne $t0, $zero, done



add $t0, $zero, $zero



slt $t0, $t4, $s3 #if $t4 < $s3, $t0 = 1, else $t0 = 0.
beq $t0, $zero, done


add $t0, $zero, $zero



addi $t1, $zero, 45
beq $t2, $t1, done



#####else it's alive!!!!
addi $v0, $v0, 1


done:
        jr $ra
