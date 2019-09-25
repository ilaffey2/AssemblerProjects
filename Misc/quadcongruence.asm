.text
.globl main
main:
	la $a0,str1 #Load and print str1
         li $v0,4
         syscall
         
         li $v0, 5 #user inputs value a
         syscall
         
         move $s0, $v0 # save a to s0
         
         la $a0,str2 #Load and print str2
         li $v0,4
         syscall
         
         li $v0, 5 #user inputs value b
         syscall
         
         move $s1, $v0 # save b to s1
         
         la $a0,str3 #Load and print str3
         li $v0,4
         syscall
         
         li $v0, 5 #user inputs value c
         syscall
         
          move $s2, $v0 # save c to s2
         
         la $a0,str4 #Load and print str4
         li $v0,4
         syscall
         
        
         
loop:    addi $t0,$t0,1 	#increment t0
	mul $t1,$t0,$t0		#square t0 store in t1
	rem $t2, $t1, $s1	#store mod of t1/s1 in t2
	rem $t3, $s0, $s1	#store mod of s0/s1 in t3
	bne $t3, $t2, noteq	#if t2 != t3 move on
	addi $t7, $t7, 1	#t7 != 0 if there are any values of x
	move $a0,$t0
	li $v0, 1
	syscall
	la $a0,strblank #Load and print strblank
         li $v0,4
         syscall
         
	
noteq:	                 
	bne $t0, $s2, loop	#break when t0 = c
	
	bne $t7, $0, end
	
	la $a0,str5 #Load and print str5
         li $v0,4
         syscall
         
	
end:	li $v0,10 #end program
         syscall

.data
	str1:  .asciiz "Enter value a: \n"
        str2:  .asciiz "Enter value b: \n"
        str3:  .asciiz "Enter value c: \n"
        str4:  .asciiz "The values of x for which the congruence holds are: \n"
        str5:   .asciiz "None"
        strblank: .asciiz "\n"
