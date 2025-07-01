.data
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
    .asciiz "Start!"
.text

main:
    li $t0, 0x10008000 # bitmap first address
    li $t1, 0x10108000 # bitmap last address
    
    la $s0, lanes # lane pointer
    li $s1, 4 # number of lanes
    li $s2, 0 # current lane index
    
draw_lanes:
    bge $s2, $s1, hold_for_z
    
    lw $t2, 0($s0)
    lw $t3, 4($s0)
    lw $t4, 8($s0)
    lw $t5, 12($s0)
    
    li $t6, 0

lane_y:
    bge $t6, $t4, next_lane
    
    li $t7, 0
    
lane_x:
    bge $t7, $t3, inc_y
    
    add $t8, $t2, $t7
    bge $t8, 256, skip
    
    sll $t9, $t6, 8
    add $t9, $t9, $t8
    sll $t9, $t9, 2
    add $t9, $t9, $t0
    
    bgeu $t9, $t1, skip
    sw $t5, 0($t9)
    
skip:
    addiu $t7, $t7, 1
    j lane_x
    
inc_y:
    addiu $t6, $t6, 1
    j lane_y
    
next_lane:
    addiu $s2, $s2, 1
    addiu $s0, $s0, 16
    j draw_lanes

hold_for_z:
    li $t2, 0xFFFF0000
    li $t3, 0xFFFF0004
    
wait:
    lw $t4, 0($t2)
    beq $t4, $zero, wait
    lw $t5, 0($t3)
    li $t6, 122
    bne $t5, $t6, wait
    
    li $v0, 4
    la $a0, start_message
    syscall
    j done

done:
    j done
    
    
    
