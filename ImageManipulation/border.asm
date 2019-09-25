#name: Ian Laffey
#studentID: 260820791

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 


	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
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


bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
	li $t0, 24	
	li $t1, 7	#24x7 array
	li $t2,0	
	li $t3,0	#increment variables
	li $s0, 49
	li $s1, 53
	li $s2, 32	#commonly used ascii values
	lb $a2, 0($a2)	#load borderwidth
	move $s3, $a2	#copy for later
	mul $t2, $a2, 2
	add $t1,$t2,$t1
	add $t0,$t2,$t0	#new dimensions
	move $t2, $0
loop1:  sb $s0, ($a1)
	sb $s1, 1($a1)
	sb $s2, 2($a1)	#store "15 "
	addi $a1, $a1, 3 #increment bufferpointer
	addi $t2, $t2, 1 #increment
	bne $t2, $t0, loop1 #for loop - while i < width
	addi $t3, $t3, 1
	move $t2, $0	#reset i
	bne $t3, $a2, loop1	#outer for loop while j < height
	move $t2, $0
	move $t3, $0
	
	#we have now printed the top bar for our border
	
loop2: 	sb $s0, ($a1)	#for loop for left side of border containing original image
	sb $s1, 1($a1)
	sb $s2, 2($a1)
	addi $a1, $a1, 3
	addi $t2, $t2, 1
	bne $t2, $a2, loop2
	move $t2, $0
	
loop3: 	lb $t4, ($a0)	#original image in middle
	sb $t4, ($a1)
	addi $a1, $a1, 1
	addi $a0, $a0, 1
	addi $t2, $t2, 1
	bne $t2, 71, loop3
	move $t2, $0
	
loop4: 	sb $s0, ($a1)	#for loop for right side of border containing original image
	sb $s1, 1($a1)
	sb $s2, 2($a1)
	addi $a1, $a1, 3
	addi $t2, $t2, 1
	bne $t2, $a2, loop4 #we now have a row of our image with border on either side
	move $t2, $0
	addi $t3, $t3, 1 #reset i and proceed for all rows of image
	bne $t3, 7, loop2
	move $t3, $0	#now that whole image has borders on left and right
	move $t2, $0	#print border on bottom 
loop5:  sb $s0, ($a1)
	sb $s1, 1($a1)
	sb $s2, 2($a1)
	addi $a1, $a1, 3
	addi $t2, $t2, 1
	bne $t2, $t0, loop5
	addi $t3, $t3, 1
	move $t2, $0
	bne $t3, $a2, loop5
	jr $ra

writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
	move $t0,$a1 #copy a1
	
	la $t1, headerbuff	#we will be saving to the headerbuffer
	li $t2, 80		
	sb $t2, ($t1)
	li $t2, 50
	sb $t2, 1($t1)
	li $t2, 10
	sb $t2, 2($t1)		#put necessary pre-determined values in header
	blt $s3, 3, s1		#if border > 3 requires ascii tricks
	li $t2, 51
	sb $t2 3($t1)		#put down 3
	addi $t2, $s3, 42
	add $t2, $t2, $s3
	sb $t2 4($t1)		#put down second digit
	j s0
s1:	li $t2, 50		#if border < 3
	sb $t2, 3($t1)		#put down 2
	addi $t2, $s3, 52
	add $t2, $t2, $s3	#then second digit
	sb $t2 4($t1)		
s0:	li $t2, 32		#put space
	sb $t2 5($t1)
	blt $s3, 2, s2		#if border <2, special case
	li $t2, 49
	sb $t2, 6($t1)
	addi $t2, $s3, 45
	add $t2, $t2, $s3	#put down one then second digit
	sb $t2, 7($t1)
	j s3
s2:	li $t2, 48		#put down 0 then second digit
	sb $t2, 6($t1)
	addi $t2, $s3, 55
	add $t2, $t2, $s3
	sb $t2, 7($t1)	
	
s3:	li $t2, 10		#add rest of the header
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
	la $a1, headerbuff		#write the specified characters as seen on assignment PDF:
	li $a2, 12
	syscall

	li $v0, 15
	move $a1, $t0		#write the content stored at the address in $a1.
	li $a2, 2048
	syscall
		
	li $v0, 16
	syscall

	jr $ra
	
	
cvrt:	
