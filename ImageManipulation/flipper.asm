#name: Ian Laffey
#studentID: 260820791

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped66.pgm"	#used as output
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line
emessage: .asciiz "There was an error!\n"
finalbuff: .space 2048
header: .asciiz "P2\n24 7\n15\n"

	.text
	.globl main

main:
	li $s0, 32
	li $s1, 10
   	 la $a0,input	#readfile takes $a0 as input
   	 jal readfile
	
	
	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip

	
fin:	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
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


flip:
	move $s2, $a1
	move $t1, $0 	#increment
	move $t0, $0
	
	
	j pixelint	#convert ascii to int array 
f2:	li $t2, 0	
	li $t3, 0
	
	
	
	
	move $t2, $0
	li $v0, 1
	la $t0, ($s2)	#array containing ints 
	move $t2, $0
	la $t1, finalbuff #array to flip to
	move $t3, $0
	lb $a2, ($a2)	#get byte for flip direction
	beq $a2, 1, yflip	#1 for y 0 for x
	
	addi $t1, $t1, 144	#offset to start from for y flipping
		
xflplp:lb $t4, ($t0)		#load byte from array of ints
	addi $t0, $t0, 1	#increment pointer
	sb $t4, ($t1)		#save to new array
	addi $t1, $t1, 1	
	addi $t3, $t3, 1	#increment stuff
	bne $t3, 24, xflplp	#run loop 24 times over (whole row)
	move $t3, $0		#reset increment for inner loop
	addi $t1, $t1, -48	#go down to start of row before
	addi $t2, $t2, 1	#increment outer loop
	bne $t2, 7, xflplp	#run loop 7 times (# of columns)
	
	j eof
	
yflip:	addi $t1, $t1, 24	#same as xflip except offset is different
yflplp: lb $t4, ($t0)
	addi $t0, $t0, 1
	sb $t4, ($t1)
	addi $t1, $t1, -1	#and we increment backwards to save to new array
	addi $t3, $t3, 1
	bne $t3, 24, yflplp
	move $t3, $0
	addi $t1, $t1, 48	#and we have to jump forward instead of backwards 2 rows after we fill
	addi $t2, $t2, 1
	bne $t2, 7, yflplp
	
eof:

	
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
	lb $t0, 0($a0) #load byte from buffer
	addi $a0, $a0, 1 #increment buffer pointer by 1
	blt $t0,48,pixelint 
	bgt $t0, 57, pixelint #check if ascii is int, if not restart loop
	addi $t0,$t0, -48 #convert from ascii to int
	beq $t1, 1, alt #if first then dont need to check char bbefore
	lb $t2,-2($a0) #load char before one we've been evaluating
	blt $t2,48,alt 
	bgt $t2, 57, alt #check if char is ascii
	addi $t2,$t2, -48
	mul $t2, $t2, 10 #if not, multiply previous int by 10
	
	add $t0,$t0,$t2 #add number and previous number
	
	sb $t0,-1($a1) #store at space before
	addi $a0,$a0,1

	
	j pixelint
	

alt: 	sb $t0,0($a1)
	addi $a1, $a1, 1 #store byte, increment pointer buffer and continue loop
	
	j pixelint

error:
	li $v0,4
	la $a0, emessage
	syscall
	
	j fin


writefile:
	move $t0,$a1 #copy a1

	li $v0,13
	li $a1, 1 #Set to open for writing
	syscall
	
	move $a0,$v0
	li $v0, 15
	la $a1, header		#write the specified characters as seen on assignment PDF:
	li $a2, 11
	syscall
	blt $v0, $0, error
	li $v0, 15
	move $a1, $t0		#write the content stored at the address in $a1.
	li $a2, 2048
	syscall
	blt $v0, $0, error		#close the file (make sure to check for errors)
	li $v0, 16
	syscall
	blt $v0, $0,error
	jr $ra
