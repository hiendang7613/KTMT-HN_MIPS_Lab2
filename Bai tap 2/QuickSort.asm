#### Read Data from File
	
	.data
fileName:  .asciiz "C:/Users/Asus/Desktop/quick_sort/input.txt"
fileWords:  .space 1000
array_size: .word 0:1
fileOut:    .asciiz "C:/Users/Asus/Desktop/quick_sort/output.txt"
Array:		.word 0:1000
space_char: .ascii " "
null_char: .asciiz "\0"
buffer: 
       .byte 32
.text
.globl main

main:
############	#READ FILE #######################
	
	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,0           	# file flag = read (0)
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
	
	#read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
	la $a2,1000		# hardcoded buffer length
	syscall

  exit:
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall

        la $a1,fileWords #load string array
        la $s2,0 #sun  = 0
        li $t0, 10 #value 10
        la $s1,Array
        la $s3,array_size
       
      
#################### STRING ARRAY -> ARRAY WORDS $################# 
#read array string from file
#read number of elements
loop_num:
     lb $t1,($a1) #load each inviadual byte
    beq $t1,13,loop_num_end
    addi $t1, $t1, -48    #converts t1's ascii value to dec value
    mul $s2, $s2, $t0    #sum *= 10
    add $s2, $s2, $t1    #sum += array[s1]-'0'
    addi $a1, $a1, 1     #increment array address
j loop_num
loop_num_end:
   add $t2, $t2, $t2    # double the index of array
   add $t2, $t2, $t2    # double the index again (now 4x)
   add $t4, $s3, $t2    # get address of ith location
   sw $s2,0($t4)
   sub $s2,$s2,$s2
   addi $a1, $a1, 2     #increment array address
   
 li $t2,0 # index = 0
 li $t3,1 #index =0 + increase
while_iter_not_end_of_string: #parse each number(string) to int
      lb $t1,($a1) #load each inviadual byte
      beq $t1,0,while_end
    #if( byte  => '0' && byte <= '9' )
    blt $t1,48,and_end #check (if byte < 0)( if true branch)
    bgt $t1,57,and_end #check (if byte > 0)( if true branch)
    addi $t1, $t1, -48    #converts t1's ascii value to dec value
    mul $s2, $s2, $t0    #sum *= 10
    add $s2, $s2, $t1    #sum += array[s1]-'0'
    addi $a1, $a1, 1     #increment array address


j while_iter_not_end_of_string

and_end:    #do if condition is true
  
     #if byte is a space assign sum -> arrray[i]
    add $t2, $t2, $t2    # double the index of array
    add $t2, $t2, $t2    # double the index again (now 4x)
    add $t4, $s1, $t2    # get address of ith location
    move $t6,$s2
    sw $t6,0($t4) #assign sum -> array[i]
    sub $s2,$s2,$s2 #reset sum = 0
    sub $t2,$t2,$t2 #reset index = 0
    add $t2,$t2,$t3 #index= index + increasement
    add $t3,$t3,1 #increasement = increasement+1
    addi $a1, $a1, 1     #increment array address
    
   j while_iter_not_end_of_string
while_end:
   #set the final number of the string to the array ( if reach "\0" the code will branch to this lable, so the final number of the string is not assign to the array)
   add $t2, $t2, $t2    # double the index of array
   add $t2, $t2, $t2    # double the index again (now 4x)
   add $t4, $s1, $t2    # get address of ith location
   move $t6,$s2
   sw $t6,0($t4) #assign sum -> array[i]
   
   
#### QUICK SORT #########

# Call quick sort
	la		$a0, Array
	li		$a1, 0   
        # a2 = Array_size - 1
	lw      $t0, array_size
	addi	$t0, $t0, -1
	move	$a2, $t0
	# function call
	jal		QUICK

 #### OUTPUT TO FILE ########
    la $s1,Array
    la $a2,array_size
    lw $t7,($a2)
    li $t8,0 #index
    li,$t9,1 #increasement
    li $s7,1 #count size
  
#####################################
# Open (for writing) a file that does not exist
li   $v0, 13       # system call for open file
la   $a0, fileOut  # output file name
li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
li   $a2, 0        # mode is ignored
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

loop_to_write_to_file: 
   
    beq $t8,$t7,end_output
    add $t8, $t8, $t8    # double the index of array
    add $t8, $t8, $t8    # double the index again (now 4x)
    add $t5, $s1, $t8    # get address of ith location
    
      lw   $a3, 0($t5)      # a number
      jal  itoa
itoa:
      la   $t0, buffer    # load buf
      add  $t0, $t0, 32   # seek the end
      li   $t1, '0'  
      sb   $t1, ($t0)     # init. with ascii 0
      li   $t3, 10        # preload 10
      beq  $a3, $0, iend  # end if 0
      #neg  $a0, $a0
loop:
      add $s7,$s7,1      #count how many munber are there
      div  $a3, $t3       # a /= 10
      mflo $a3
      mfhi $t4            # get remainder
      add  $t4, $t4, $t1  # convert to ASCII digit
      sb   $t4, ($t0)     # store it
      sub  $t0, $t0, 1    # dec. buf ptr
      bne  $a3, $0, loop  # if not zero, loop
      addi $t0, $t0, 1    # adjust buf ptr
iend:
###############################################################
# Write to file just opened
li   $v0, 15       # system call for write to file
move $a0, $s6      # file descriptor 
la $a1,($t0)      # address of buffer from which to write
add $a2,$a2,$s7   #calc hardcored size to print out
syscall

la $t0,buffer
sub $t0,$t0,$t0 #reset buffer
li $s7,2 #reset 
li $a2,0 #reset

sub $t8,$t8,$t8 #reset index = 0
add $t8,$t8,$t9 #index= index + increasement
add $t9,$t9,1 #increasement = increasement+1

j loop_to_write_to_file


end_output:
###############################################################
# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file
###############################################################


# end program
	li		$v0, 10
	syscall


QUICK:
## quick sort

# store $s and $ra
	addi	$sp, $sp, -24	# Adjest sp
	sw		$s0, 0($sp)		# store s0
	sw		$s1, 4($sp)		# store s1
	sw		$s2, 8($sp)		# store s2
	sw		$a1, 12($sp)	# store a1
	sw		$a2, 16($sp)	# store a2
	sw		$ra, 20($sp)	# store ra

# set $s
	move	$s0, $a1		# l = left
	move	$s1, $a2		# r = right
	move	$s2, $a1		# p = left

# while (l < r)
Loop_quick1:
	bge		$s0, $s1, Loop_quick1_done
	
# while (arr[l] <= arr[p] && l < right)
Loop_quick1_1:
	li		$t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult	$s0, $t7
	mflo	$t0				# t0 =  l * 4bit
	add		$t0, $t0, $a0	# t0 = &arr[l]
	lw		$t0, 0($t0)
	# t1 = &arr[p]
	mult	$s2, $t7
	mflo	$t1				# t1 =  p * 4bit
	add		$t1, $t1, $a0	# t1 = &arr[p]
	lw		$t1, 0($t1)
	# check arr[l] <= arr[p]
	bgt		$t0, $t1, Loop_quick1_1_done
	# check l < right
	bge		$s0, $a2, Loop_quick1_1_done
	# l++
	addi	$s0, $s0, 1
	j		Loop_quick1_1
	
Loop_quick1_1_done:

# while (arr[r] >= arr[p] && r > left)
Loop_quick1_2:
	li		$t7, 4			# t7 = 4
	# t0 = &arr[r]
	mult	$s1, $t7
	mflo	$t0				# t0 =  r * 4bit
	add		$t0, $t0, $a0	# t0 = &arr[r]
	lw		$t0, 0($t0)
	# t1 = &arr[p]
	mult	$s2, $t7
	mflo	$t1				# t1 =  p * 4bit
	add		$t1, $t1, $a0	# t1 = &arr[p]
	lw		$t1, 0($t1)
	# check arr[r] >= arr[p]
	blt		$t0, $t1, Loop_quick1_2_done
	# check r > left
	ble		$s1, $a1, Loop_quick1_2_done
	# r--
	addi	$s1, $s1, -1
	j		Loop_quick1_2
	
Loop_quick1_2_done:

# if (l >= r)
	blt		$s0, $s1, If_quick1_jump
# SWAP (arr[p], arr[r])
	li		$t7, 4			# t7 = 4
	# t0 = &arr[p]
	mult	$s2, $t7
	mflo	$t6				# t6 =  p * 4bit
	add		$t0, $t6, $a0	# t0 = &arr[p]
	# t1 = &arr[r]
	mult	$s1, $t7
	mflo	$t6				# t6 =  r * 4bit
	add		$t1, $t6, $a0	# t1 = &arr[r]
	# Swap
	lw		$t2, 0($t0)
	lw		$t3, 0($t1)
	sw		$t3, 0($t0)
	sw		$t2, 0($t1)
	
# quick(arr, left, r - 1)
	# set arguments
	move	$a2, $s1
	addi	$a2, $a2, -1	# a2 = r - 1
	jal		QUICK
	# pop stack
	lw		$a1, 12($sp)	# load a1
	lw		$a2, 16($sp)	# load a2
	lw		$ra, 20($sp)	# load ra
	
# quick(arr, r + 1, right)
	# set arguments
	move	$a1, $s1
	addi	$a1, $a1, 1		# a1 = r + 1
	jal		QUICK
	# pop stack
	lw		$a1, 12($sp)	# load a1
	lw		$a2, 16($sp)	# load a2
	lw		$ra, 20($sp)	# load ra
	
# return
	lw		$s0, 0($sp)		# load s0
	lw		$s1, 4($sp)		# load s1
	lw		$s2, 8($sp)		# load s2
	addi	$sp, $sp, 24	# Adjest sp
	jr		$ra

If_quick1_jump:

# SWAP (arr[l], arr[r])
	li		$t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult	$s0, $t7
	mflo	$t6				# t6 =  l * 4bit
	add		$t0, $t6, $a0	# t0 = &arr[l]
	# t1 = &arr[r]
	mult	$s1, $t7
	mflo	$t6				# t6 =  r * 4bit
	add		$t1, $t6, $a0	# t1 = &arr[r]
	# Swap
	lw		$t2, 0($t0)
	lw		$t3, 0($t1)
	sw		$t3, 0($t0)
	sw		$t2, 0($t1)
	
	j		Loop_quick1
	
Loop_quick1_done:
	
# return

	lw		$s0, 0($sp)		# load s0
	lw		$s1, 4($sp)		# load s1
	lw		$s2, 8($sp)		# load s2
	addi	$sp, $sp, 24	# Adjest sp
	jr		$ra




