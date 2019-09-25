#studentName: Ian Laffey
#studentID: 260820791

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
txtbuff: .space 1024
wrdbuff: .space 32
str1: .asciiz "Word count\nEnter a text segment:\n  "
str2: .asciiz "Got it!\nEnter the search word:\n  "
str3: .asciiz "\nLoading...\nLoading...\nJust kidding!\nYour word appeared "
str4: .asciiz " times."
str5: .asciiz "\n  (E)nter another text segment or (q)uit?\n"
str6: .asciiz "Quitting. Come back soon!"
str7: .asciiz "Let's run this bad boy again!\n\n\n"

	.text
	.globl main

main:	# all subroutines you create must come below "main"
	la $s0, txtbuff
	la $s1, wrdbuff		#set up some constants 
	li $s2, -1
	li $s3, 32
	
	
	la $a0, str1
			#print first prompt
	li $a1, 35
	jal write
readl1:	
	jal read
	sb $v0, ($s0)
	addi $s0,$s0,1		#get user input for text segment-store in txtbuff
	bne $v0, 10, readl1
	sb $s3, -1($s0)		#we write a space in place of the user-entered \n to save time later
	sb $0, 0($s0)		#as the loop uses spaces to see if words match
	
	
	
	la $a0, str2
	li $a1, 33		#print second prompt
	jal write
	
readl2:	
	jal read
	sb $v0, ($s1)
	addi $s1,$s1,1		#get user input for word -store in wrdbuff
	addi $s2, $s2, 1	#also stores length of word in s2
	bne $v0, 10, readl2
	
	sb $0, 1($s1)
	
	la $s0, txtbuff
	la $s1, wrdbuff
	
	
reset:	move $t2, $0	
	la $s1, wrdbuff
mnlp:	lb $t0, ($s0)		#main loop
	addi $s0, $s0, 1	#t0 = byte from text segment
	lb $t1, ($s1)		#t1 = byte from word.
	addi $s1, $s1, 1	
	beq $t0, $0, fin	#if t0 = null byte (exit condition)
	bne $t0, $t1, reset	#if t0 != t1, reset counter- we wont have a match
	#elif t0 = t1
	addi $t2, $t2, 1
	bne $t2, $s2, mnlp	#if lengths not same keep going, have to check more
	#elif we have a succesful match
	lb $t5, 0($s0)
	
	bne $t5, 32, reset
	addi $t3, $t3, 1
	j reset
	
fin:	la $a0, wrdbuff
	addi $t3, $t3, 48	#the brunt of our work is now done. t3 holds our value we want to return, convert it to ascii
	sb $t3, 31($a0)		#ok so this is kinda ghetto, but my write function reads from an address in memory
	move $a1, $s2		#and i didnt feel like making a whole new function so we're gonna store the value we want to print
	jal write		#at the end of one of our buffers
	la $a0, str3
	li $a1, 56
	jal write
	la $a0, wrdbuff+31
	li $a1, 1
	jal write		#now we're just printing out the rest of the strings, giving the user the information
	la $a0, str4
	li $a1, 7
	jal write
	la $a0, str5
	li $a1, 43
	jal write
	
prompt:	jal read
	beq $v0, 113, quit	#prompt the user to quit or restart game, if they press anything else nothing happens
	bne $v0, 101, prompt
	la $a0, str7
	li $a1, 32
	jal write
	move $v0, $0
	move $a0, $0
	move $a1, $0
	move $t0, $0		#better safe than sorry. Just resetting registers before restarting the program
	move $t1, $0		#because i dont want any weird bugs coming from that.
	move $t2, $0
	move $t3, $0
	move $t4, $0		#and then we just go right back to main, and restart program
	j main
quit:   la $a0, str6		#on quitting we print a nice little string saying by, and finish off with a syscall
	li $a1, 25
	jal write
	li $v0, 10
     	syscall



	
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
	