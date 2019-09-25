#studentName:Ian Laffey
#studentID:260820791

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line 
array: .space 32
str1: .asciiz "Welcome to QuickSort\n--------------------\n"
str2: .asciiz "\nThe array is re-initialized\n"
str3: .asciiz "\nThe sorted array is:  "
str4: .asciiz "\n-----------------\nExiting QuickSort"


	.text
	.globl main

main:	# all subroutines you create must come below "main"
	la $s0, array
	li $s2, 0 	#s2 = length of array 
	li $s3, 10	#newline char
	la $a0, str1
	li $a1, 42
	jal write
	
mnlp:	jal read
	beq $v0, 32, space
	beq $v0, 113, end	#main loop that runs whole program
	beq $v0, 99, clr	#gets user input from read and then goes to corresponding key press
	beq $v0, 115, stadp
	slti $t0, $v0, 58    
	sgt  $t1, $v0, 47    
	and  $t0, $t1, $t0	#this just checks if 48<v0<57
	bne $t0, $0, digit
	j mnlp
	
end:	la $a0, str4
	li $a1, 36	#print string for end of program and quit
	jal write
	
	li $v0, 10
	syscall

stadp:	beq $s2, $0, mnlp	#sort and display
	la $a0, array
	li $a1, 0
	add $a2, $s2, -1
	jal qksrt
	
	la $a0, str3
	li $a1, 23
	jal write
	
	lui $t0, 0xffff
	la $t2, array
	move $t4, $0
stwl:	lw $t1, 8($t0) 
	andi $t1,$t1,0x0001	
	beq $t1,$zero, stwl
	lb $t3, ($t2)
	addi $t2, $t2, 1
	bge $t3, 10, sttg
	addi $t3, $t3, 48
	sw $t3, 12($t0)
	
spwl2:	lw $t1, 8($t0) 
	andi $t1,$t1,0x0001	#echo space
	beq $t1,$zero, spwl2
	li $t1, 32
	sw $t1, 12($t0)
	addi $t4, $t4, 1
	
stchk:	bne $t4, $s2, stwl
	sw $s3, 12($t0)
	j mnlp
	
	
sttg:	div $t3, $s3
	mflo $t3
	addi $t3, $t3, 48
	sw $t3, 12($t0)
	mfhi $t3
	addi $t3, $t3, 48
	sw $t3, 12($t0)
	addi $t4, $t4, 1
	
spwl3:	lw $t1, 8($t0) 
	andi $t1,$t1,0x0001	#echo space
	beq $t1,$zero, spwl3
	li $t1, 32
	sw $t1, 12($t0)
	
	j stchk
	
	

clr:	la $a0, str2
	li $a1, 29
	jal write
	li $t0, -1
clrlp:	sb $0, ($s0)
	addi $s0, $s0, -1
	addi $t0, $t0, 1
	bne $t0, $s2, clrlp
	move $s2, $0
	la $s0, array
	j mnlp


space:	lui $t0, 0xffff
spwl:	lw $t1, 8($t0) 
	andi $t1,$t1,0x0001	#echo space
	beq $t1,$zero, spwl
	li $t1, 32
	sw $t1, 12($t0)
	
	beq $s1, $0, mnlp	#0 items in stack
	beq $s1, 1, odsp	#1 digit in stack
	lw $t1, 0($sp)		
	addi $sp, $sp, 4
	lw $t0, 0($sp)		#2 digit in stack
	addi $sp, $sp, 4	#get first digit, get second digit multiply second by 10 and add
	mul $t0, $t0, 10
	add $t0, $t0, $t1
	sb $t0, ($s0)		#store bytes to array
	addi $s0, $s0, 1
	move $s1, $0
	addi $s2, $s2, 1
	j mnlp			#return to array
odsp:	lw $t0, 0($sp)
	addi $sp, $sp, 4	#one digit is easy, just get it from the stack and add it to array
	sb $t0, 0($s0)
	addi $s0,$s0,1
	move $s1, $0
	addi $s2, $s2, 1
	j mnlp
	
digit:  lui $t0, 0xffff
dgwl:	lw $t1, 8($t0) 
	andi $t1,$t1,0x0001	#echo digit
	beq $t1,$zero, dgwl
	sw $v0, 12($t0)
	
	addi $s1, $s1, 1
	addi $sp, $sp, -4	#convert from ascii to int, save the int onto stack to be
	addi $v0, $v0, -48	#taken off by space
	sw $v0, 0($sp)
	j mnlp

qksrt:	#a0-arr t1-low t2-hi t3-pivot
	ble $a2, $a1, qksrte	#if hi < low then return
	move $t1, $a1
	move $t2, $a2
	
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal partn	#save necessary registers to stack, call partition
	lw $ra, 0($sp)
	addi $sp,$sp,4
	lw $t2, 0($sp)
	addi $sp,$sp,4
	lw $t1, 0($sp)
	addi $sp,$sp,4
	
	move $t3, $v0 #pivot=partition 
	
	addi $t4, $t3, -1
	move $a1, $t1		#calling qksrt recursively
	move $a2, $t4
	
	addi $sp, $sp, -4	#first call quicksort(a,low,pivot-1)
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4	#save to stack
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal qksrt		#call
	lw $ra, 0($sp)
	addi $sp,$sp,4
	lw $t3, 0($sp)
	addi $sp,$sp,4
	lw $t2, 0($sp)		#get back from stack
	addi $sp,$sp,4
	lw $t1, 0($sp)
	addi $sp,$sp,4
	lw $t0, 0($sp)
	addi $sp,$sp,4
	
	addi $t4, $t3, 1
	move $a1, $t4		#then call quicksort(a,pivot+1,hi)
	move $a2, $t2
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal qksrt		#call quicksort again
	lw $ra, 0($sp)
	addi $sp,$sp,4
	lw $t3, 0($sp)
	addi $sp,$sp,4
	lw $t2, 0($sp)
	addi $sp,$sp,4
	lw $t1, 0($sp)
	addi $sp,$sp,4
	lw $t0, 0($sp)
	addi $sp,$sp,4
	
	

qksrte: jr $ra


partn:	move $t0, $a0		#a
	add $t1, $t0, $a1	
	lb $t1, ($t1)		#pivot
	move $t2, $a1		#p_pos
	move $t3, $a2		#hi
	move $t4, $a1
	move $t5, $a1		#low
	add $t0, $t4, $t0
	addi $t0, $t0, 1
partlp:	addi $t4, $t4, 1	#increment
	lb $t6, ($t0) 		#a[i]
	addi $t0, $t0, 1
	bge $t6, $t1, prtlpe	
	# a[i] < pivot
	addi $t2, $t2, 1
	move $a1, $t2
	move $a2, $t4
	
				#swap ready to be called just need to save onto stack
				
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal swap
	lw $ra, 0($sp)
	addi $sp,$sp,4
	lw $t3, 0($sp)
	addi $sp,$sp,4
	lw $t2, 0($sp)
	addi $sp,$sp,4
	lw $t1, 0($sp)
	addi $sp,$sp,4
	lw $t0, 0($sp)
	addi $sp,$sp,4
	
prtlpe:	blt $t4,$t3,partlp
	
	move $a1,$t5	#call swap for last time, this time we dont need to save to stack
	move $a2,$t2	#except for $ra because we're at the end
	move $v0, $t2
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal swap
	lw $ra, 0($sp)
	addi $sp,$sp,4
	
	jr $ra
	


swap: 	move $t0, $0
	move $t1, $0		#swap a0[a1] with a0[a2]
	add $t2, $a1, $a0
	add $t3, $a2, $a0	#just need to use temp variables
	lb $t0, ($t2)
	lb $t1, ($t3)
	sb $t0, ($t3)
	sb $t1, ($t2)
	jr $ra
	
read: lui $t0, 0xffff #ffff0000
iL2:
	lw $t1, 0($t0) #control
	andi $t1,$t1,0x0001
	beq $t1,$zero, iL2
	lw $v0, 4($t0) #data
	jr $ra
	
write:	lui $t0, 0xffff #ffff0000
	move $t4, $0
iL1:
	lw $t1, 8($t0) #control
	andi $t1,$t1,0x0001
	beq $t1,$zero, iL1
	lb $t1, ($a0)
	
	sw $t1, 12($t0) #dat
	addi $a0, $a0, 1
	addi $t4, $t4, 1
	bne $t4, $a1, iL1

	jr $ra
	
