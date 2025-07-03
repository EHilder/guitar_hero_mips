.data
speed: .word 500
lanes:
    .word 42 	# First lane starting x
    .word 24 	# First lane width
    .word 256 	# First lane height
    .word 0xFFFF00B4 	# First lane color
    
    .word 92 	# Second lane starting x
    .word 24	# Second lane width
    .word 256	# Second lane height
    .word 0xFFFF00B4	# Second lane color
    
    .word 142 	# Third lane starting x
    .word 24	# Third lane width
    .word 256	# Third lane height
    .word 0xFFFF00B4	# Third lane color
    
    .word 192 	# Fourth lane starting x
    .word 24	# Fourth lane width
    .word 256	# Fourth lane height
    .word 0xFFFF00B4	# Fourth lane color

notes:
    .word 2317, 0
    .word 19832, 1
    .word 20065, 2
    .word 20265, 1
    .word 20468, 2
    .word 20669, 3
    .word 20870, 3
    .word 21151, 2
    .word 21351, 3
    .word 21598, 2
    .word 21799, 2

start_message:
    .asciiz "Start!\n"

.text
main:
    li $t0, 0x10008000 # bitmap first address
    li $t1, 0x10108000 # bitmap last address
    
    la $s0, lanes # lane pointer
    li $s1, 4 # lanes length
    li $s2, 0 # current lane index
    
draw_lanes:
    bge $s2, $s1, hold_for_z # if lane index greater than number of lanes, branch to hold_for_z
    
    lw $t2, 0($s0) # load lane x
    lw $t3, 4($s0) # load lane width
    lw $t4, 8($s0) # load lane height
    lw $t5, 12($s0) # load lane color
    li $t6, 0 # set current row (y) to 0 for top of lane

lane_y:
    bge $t6, $t4, next_lane # if current row (y) is greater than lane height, branch to next_lane
    
    li $t7, 0 # set current x offset to 0 for start of row
    
lane_x:
    bge $t7, $t3, inc_y # if the x offset is greater than the width, branch to inc_y
    
    add $t8, $t2, $t7 # add the x starting position and the x offset to get the current x
    bge $t8, 256, skip # if the current x position is off the screen, skip
    
    sll $t9, $t6, 8 # multiply the current row value by 256 to convert to memory address
    add $t9, $t9, $t8 # add the address offset to the current row value
    sll $t9, $t9, 2 # multiply by 4 as pixels are 4 bytes
    add $t9, $t9, $t0 # add the full memory offset to the base address
    
    bgeu $t9, $t1, skip # compare unsigned (memory address), and if the memory address is greater than the last bitmap address, skip
    sw $t5, 0($t9) # store color in pixel memory address
    
skip:
    addiu $t7, $t7, 1 # add 1 to the current x offset
    j lane_x # call pixel draw function again
    
inc_y:
    addiu $t6, $t6, 1 # add to the current row (y) by 1
    j lane_y # jump back to the lane_y function
    
next_lane:
    addiu $s2, $s2, 1 # add 1 to the lane index counter
    addiu $s0, $s0, 16 # add 1 to the lane offset
    j draw_lanes # jump to the draw_lanes function

hold_for_z:
    li $t2, 0xFFFF0000 # load the keyboard status address into $t2
    li $t3, 0xFFFF0004 # load the keyboard data address into $t3
    
wait:
    lw $t4, 0($t2) # load the value of the address stored at $t2 into $t4
    beq $t4, $zero, wait # branch back to the start of the wait function if the status is 0
    lw $t5, 0($t3) # otherwise, check the value stored at the keyboard data address
    li $t6, 122 # load the ascii value for 'z' into $t6
    bne $t5, $t6, wait # branch back to the start of the wait function if the data in the keyboard address is not 'z'
    
start:
    li $v0, 4 # load syscall 4 for printing a message
    la $a0, start_message # load the syscall argument register with the start message from .data 
    syscall # run syscall
    
    la $s3, notes # note pointer 
    li $s4, 11 # notes length
    li $s5, 0  # current note index
    j game_loop # jump to gameloop

game_loop:
    jal notes_loop # jump to notes loop and load each note if applicable before prompting user key
    jal input_main
    
notes_loop:
    bge $s5, $s4, return_to_game_loop # jump to return function
    lw $t2, 0($s3) # load note
    lw $t3, 4($s3) # load lane width
    lw $t4, 8($s3) # load lane height
    
    # what now?
    
    addi $s4, $s4, 1
    j notes_loop
    
return_to_game_loop:
    jr $ra # return to game_loop

input_main:
    li $t2, 0xFFFF0000 # load keyboard status again
    li $t3, 0xFFFF0004 # load keyboard data again
    lw $t4, 0($t2) # load the value of the address stored at $t2 into $t4
    beq $t4, $zero, input_main # branch back to the start of the input_main function if the status is 0
    lw $t5, 0($t3) # otherwise, check the value stored at the keyboard data address
    li $t6, 97 # load the ascii value for 'a' into $t6
    beq $t5, $t6, a_handler # branch back to the start of the a_handler function if the data in the keyboard address is 'a'
    li $t6, 115 # load the ascii value for 's' into $t6
    beq $t5, $t6, s_handler # branch back to the start of the s_handler function if the data in the keyboard address is 's'
    li $t6, 100 # load the ascii value for 'd' into $t6
    beq $t5, $t6, d_handler # branch back to the start of the d_handler function if the data in the keyboard address is 'd'
    li $t6, 102 # load the ascii value for 'f' into $t6
    beq $t5, $t6, f_handler # branch to the f_handler function if the data in the keyboard address is 'f'
    sw $zero, 0($t2)
    j return_to_game_loop
    
a_handler:
    sw $zero, 0($t2) #zero out keyboard status
    j return_to_game_loop # handle a inputs
    
    
s_handler:
    sw $zero, 0($t2) #zero out keyboard status
    j return_to_game_loop # handle s inputs
    
d_handler:
    sw $zero, 0($t2) #zero out keyboard status
    j return_to_game_loop # handle d inputs
    
f_handler:
    sw $zero, 0($t2) #zero out keyboard status
    j return_to_game_loop # handle f inputs
    
    
    
