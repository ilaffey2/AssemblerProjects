#name: Ian Laffey
#studentID: 260820791

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped69.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 2
y1: .word 3
y2: .word 4
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 
emessage: .asciiz "There was an error!\n"
finalbuff: .space 2048
header: .asciiz "P2\n7 24\n15\n"
	.text
	.globl main

main:	li $s0, 32
	li $s1, 10
	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	lb $a0, x1
    	lb $a1, x2
    	lb $a2, y1
    	lb $a3, y2
    	la $t0, buffer
    	la $t1, newbuff
    	sb $t0, 16($sp)
    	sb $t1, 20($sp)
	jal crop

fin:	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	li $v0,13 	#Open the file to be read,using $a0
	syscall


	move $t0, $v0		# You will want to keep track of the file descriptor*

	li $v0,14		# read from file
	move $a0, $t0
	la $a1, buffer		# use correct file descriptor, and point to buffer
	li $a2, 2048		# hardcode maximum number of chars to read
	syscall		# read from file

		# address of the ascii string you just read is returned in $v1.
	li $v0, 16		# the text of the string is in buffer
	syscall		# close the file

	move $v0,$v1
	jr $ra


crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.

	move $t1, $0 	#increment
	move $t0, $0
	la $s2, 16($sp)
	la $t4, 16($sp)
	la $t5 20($sp)
	
	j pixelint	#convert ascii to int array 
f2:	move $t2, $a0	
	move $t3, $a2
	move $t0, $t4
	move $t1, $t5
	mul $t5, $a2, 24
	addi $t6, $a1, -24	#didn't manage to properly implement this although I did setup the header correctly (partial marks? :) )
	mul $t6, $t6, -1	#my idea here was to start t0 at an offset determined by arguments, and go until it reached the end,
	addi $t7, $a3, -7	#then go to the offset on the next line etc, while incrementing t1...
	mul $t7, $t7, -1	#however I ran out of time
	add $t0, $t0, $a0	
	add $t0, $t0, $t5
	
loop:	lb $t4, ($t0)
	addi $t0, $t0, 1
	sb $t4, ($t1)
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	bne $t2, $a1, loop
	add $t0, $t0, $t6
	add $t0, $t0, $a0
	addi $t3, $t3, 1
	bne $t3, $a3, loop
	
	la $t0, finalbuff	#writing out of finalbuff into newbuff
	la $t1, ($s2)		#finalbuff contains the array in the correct order, but its still ints
	move $t2, $0		#newbuff will contain the final array, with ascii instead of ints, and spaces
loop44:	addi $t2, $t2, 1	
	lb $t3, ($t0)		#load byte from finalbuff
	bgt $t3, 9, td		# if one digit our job is easy, else go to two digit section
	addi $t3,$t3,48		#convert to ascii
	sb $t3, ($t1)		#store byte
	sb $s0, 1($t1)		#store a space
	addi $t1, $t1, 2	#increment newbuff after we're done
	j foo			#skip steps for two digit numbers
td:	div $t3, $s1
	mflo $t4
	addi $t4, $t4, 48	#if two digits the idea is the same as one digit
	sb $t4, ($t1)		#except we have to use the div command to get the first and second digit
	mfhi $t4		#then its the same, convert them both to ascii, store them, and store a space after
	addi $t4, $t4, 48
	sb $t4, 1($t1)
	sb $s0, 2($t1)
	addi $t1,$t1,3	
foo:	addi $t0, $t0, 1
	bne $t2, 168, loop44	#do all of this 168 times, so we can do the whole image
	j fin
	
	
	
pixelint:
	
	addi $t1,$t1,1 
	bgt $t1,504, f2 #for loop, run 169 times (24x7)
	lb $t0, 0($t4) #load byte from buffer
	addi $t4, $t4, 1 #increment buffer pointer by 1
	blt $t0,48,pixelint 
	bgt $t0, 57, pixelint #check if ascii is int, if not restart loop
	addi $t0,$t0, -48 #convert from ascii to int
	beq $t1, 1, alt #if first then dont need to check char bbefore
	lb $t2,-2($t4) #load char before one we've been evaluating
	blt $t2,48,alt 
	bgt $t2, 57, alt #check if char is ascii
	addi $t2,$t2, -48
	mul $t2, $t2, 10 #if not, multiply previous int by 10
	
	add $t0,$t0,$t2 #add number and previous number
	
	sb $t0,-1($t5) #store at space before
	addi $t4,$t4,1

	
	j pixelint
	

alt: 	sb $t0,0($t5)
	addi $t5, $t5, 1 #store byte, increment pointer buffer and continue loop
	
	j pixelint
	

writefile:
	move $t0,$a1 #copy a1
	
	la $t1, headerbuff	#we will be saving to the headerbuffer
	li $t2, 80		
	sb $t2, ($t1)
	li $t2, 50
	sb $t2, 1($t1)
	li $t2, 10
	sb $t2, 2($t1)		#put necessary pre-determined values in header
	lb $t3, x1
    	lb $t4, x2
    	mul $t3, $t3, -1
    	add $t3, $t3, $t4
    	div $t3, $s1
    	mflo $t3
    	addi $t3, $t3, 48
    	sb $t3, 3($t1)
    	mfhi $t3
    	addi $t3,$t3,48
    	sb $t3, 4($t1)
    	sb $s0, 5($t1)
    	lb $t3, y1
    	lb $t4, y2
    	mul $t3, $t3, -1
    	add $t3, $t3, $t4
    	div $t3, $s1
    	mflo $t3
    	addi $t3, $t3, 48
    	sb $t3, 6($t1)
    	mfhi $t3
    	addi $t3,$t3,48
    	sb $t3, 7($t1)
    	
    	li $t2, 10		#add rest of the header
	sb $t2, 8($t1)
	li $t2, 49
	sb $t2, 9($t1)
	li $t2, 53
	sb $t2, 10($t1)
	li $t2, 10
	sb $t2, 11($t1)
	
	li $v0,13
	li $a1, 1 #Set to open for writing
	syscall
	
	move $a0,$v0
	li $v0, 15
	la $a1, headerbuff	#write the specified characters as seen on assignment PDF:
	li $a2, 11
	syscall
	li $v0, 15
	move $a1, $t0		#write the content stored at the address in $a1.
	li $a2, 2048
	syscall	#close the file (make sure to check for errors)
	li $v0, 16
	syscall
	jr $ra
