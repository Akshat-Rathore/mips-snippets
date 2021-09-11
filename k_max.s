##### Data Segment ###########
.data
array: 
    .space 40
array_prompt:
    .asciiz "Enter the ten elements of the array:\n"
number_prompt:
    .asciiz "Enter the value of k: "

sorted_propmt:
    .asciiz "Sorted Array:\n "

success:
    .asciiz "Kth largest Number: "
err_mssg:
    .asciiz "\n The entered number must be more than 0 and less than 10. Aborting...\n"

newline:
    .asciiz "\n"

##### Code Segment ###########
   .text
   .globl main
main:
    la $a0, array_prompt # Prompt for entering the array
    li $v0, 4
    syscall
    addi $t1, $zero, 36 # for input
    addi $t0,$zero, 0 # for input
    jal array_input # take input
    # Prompt for entering k
    la $a0, number_prompt
    li $v0, 4
    syscall
    li $v0,5 # input k
    syscall
    add $s5, $zero, $v0 # $s5 stores k

    addi $t1, $zero, 10 # number of elements in array in $t1 (=10)
    slt $t9, $t1, $s5 # sanity check
    bne $t9, $zero, sanityerror # check for sanity error in k (>10)
    ble $s5, $zero, sanityerror  # check for sanity error in k (<=0)
    addi $t3, $zero, 4
    jal sort_array
    
    la $a0, sorted_propmt # prompt for sorted data
    li $v0, 4
    syscall
    addi $t0, $zero, 0 # for output
    addi $t1, $zero, 36 # for output
    jal array_output # output
    la $a0, success # printing answer prompt
    li $v0, 4
    syscall
    addi $t3, $zero, 4 # t3 stores 4
    addi $t1, $zero, 10 # t1 stores 10
    sub $s0, $t1, $s5 # s0 stores 10- k
    sll $s1, $s0, 2 # 4*(10-k)
    # mflo $s1 # s1 stores answer
    lw $a0, array($s1) # load answer
    li $v0, 1 # print answer
    syscall
    j exit # exit

sort_array:
    addi $t0, $zero, 1 # j stored in $t0
    addi $t1, $zero, 10 # number of elements in array in $t1
    slt $t2, $t0, $t1 # j<n ? outerloop: exit
    bne $t2, $zero, outer_loop
    # ble $t0, $t1, outer_loop
    j exit_outer_l

outer_loop:
    add $t2, $zero, $t0 # j stores in t2
    sll $t2, $t2, 2 # t2 stores 4*j
    lw $s0, array($t2) # $s0 stores temp a[j]
    addi $t2, $t0, -1 # $t2 stores i (i=j-1)

check_inner:
    ble $zero, $t2, checkother # i>0? checkother: exit
    # bne $t8, $zero, checkother

outer_after_inner:
    addi $t6, $t2, 1
    sll $t6, $t6, 2
    sw $s0, array($t6)
    addi $t0, $t0, 1 # j=j+1
    slt $t2, $t0, $t1 # j<10? reiterate: exit
    bne $t2, $zero, outer_loop
    # ble $t0, $t1, outer_loop
    j exit_outer_l

checkother:
    sll $t4, $t2, 2 # t4 stores 4*i
    lw $s3, array($t4) # s3 stores a[i]
    slt $t8, $s0, $s3 # temp<a[i]? innerloop: exit
    bne $t8, $zero, inner_loop
    j outer_after_inner

inner_loop:
    addi $t5, $t2, 1 # t5 stores i+1
    sll $t5, $t5, 2 # t5 stores 4*(i+1)
    sll $s3, $t2, 2 # s3 stores 4*i
    lw $s3, array($s3) # s3 stores a[i]
    sw $s3,  array($t5) # a[i+1]=a[i]
    addi $t2, $t2, -1 # i-=1
    j check_inner # check initial conditions

exit_outer_l:
    jr $ra




array_input:        
    li $v0,5
    syscall

    sw $v0,array($t0)
    
    beq $t0, $t1, exit_input   
    addi $t0,$t0,4
    j array_input

exit_input:
    jr $ra

array_output:
    lw $v0, array($t0)
    add $a0, $v0, $zero
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    beq $t0, $t1, exit_output
    addi $t0, $t0, 4
    j array_output
    
exit_output:
    jr $ra

sanityerror:
    la $a0, err_mssg
    li $v0, 4
    syscall
    j exit

exit:
    li $v0, 10
    syscall
