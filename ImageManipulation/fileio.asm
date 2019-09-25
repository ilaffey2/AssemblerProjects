#name: Ian Laffey
#studentID: 260820791

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output

header: .asciiz "P2\n24 7\n15\n"

emessage: .asciiz "There was an error!\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile
	li $v0, 4
	la $a0, buffer
	syscall
	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

exit:	li $v0,10		# exit
	syscall

readfile:

	li $v0,13 	#Open the file to be read,using $a0
	syscall
	blt $v0, $0, error	#Conduct error check, to see if file exists

	move $t0, $v0		# You will want to keep track of the file descriptor*

	li $v0,14		# read from file
	move $a0, $t0
	la $a1, buffer		# use correct file descriptor, and point to buffer
	li $a2, 2048		# hardcode maximum number of chars to read
	syscall		# read from file

	blt $v0, $0, error		# address of the ascii string you just read is returned in $v1.
	li $v0, 16		# the text of the string is in buffer
	syscall		# close the file (make sure to check for errors)
	blt $v0, $0, error
	move $v0,$v1
	jr $ra
error:
	li $v0,4
	la $a0, emessage
	syscall
	
	j exit

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