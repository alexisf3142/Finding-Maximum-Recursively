#---------------------------------------------------------------------------------------------#
# afrancisSPIM3.asm
# Alexis Francis 
# Description: This program has a list of 50 integers in global memory, it asks the user for n
# the size of the sublist to find the maximum in that sublist using recursion and the stack.
# Input: We have a array of 50 integers in global memory, we will prompt the user to input an
# integer n which corresponds to the size of the sublist.
# Output: I output a string to ask for input for n, the size of the sublist, and I also output 
# another string indicating the maximum, which I then print an integer which is the calculated
# max value in the sublist.
# I have abided by the Wheaton College Honor Code in this work x Alexis Francis
#---------------------------------------------------------------------------------------------#
	.data
array: .word 3 12 -87 22 367 90 -2 7860 -38 720 873 796 81 4 281 65 6 -638 516 28 83 -19 55 2 92 87 33 410 -33 92 70 -4 81 362 431 256 -992 12 422 125 5 -8 30 891 211 86 578 67 15 6 
inputsize: .asciiz "please enter n, the size of the sublist\n"
maxoutput: .asciiz "\nthe maximum value of the sublist is "

#---------------------------------------------------------------------------------------------#
	.text
	.globl main
main:
	li $v0, 4					#ask for n, the size of sublist
	la $a0, inputsize
	syscall
	
	li $v0, 5					#read input of n
	syscall
	#since arrays start at 0 we do n = n-1 to get our n, etc.
	sub $a1, $v0, 1				#$a1 = n-1
	sub $a2, $a1, 1				#$a2 = n-2
	
	beq $a1, $zero, printBC		#base case if(n == 0), in c++ it's if (n == 1)
	j continue1
#prints the max if the base case is satisfied	
printBC:
	li $v0, 4
	la $a0, maxoutput
	syscall
	
	lw $a0, array($zero)
	li $v0, 1
	syscall
	j done
#if the base case is not satisfied, do this	
continue1:
	la $s0, array				#load the array into s0
	li $v1, 0					#load 0 into $v1
	
	jal helper					#start finding the max
	
	li $v0, 4
	la $a0, maxoutput
	syscall
	
	move $a0, $v1
	li $v0, 1
	syscall
	
done:
	li $v0, 10
	syscall
#-----findMax function-----#
	.data
#--------------------------#
	.text
#this is our basecase, if (n <= 0) we stop the recursion
helper:
	bgt $a1, $zero, findMax		#if (n > 0) initiate recursion
	jr $ra
#this is our findMax function, we start by making space in the stack
#using recurion we will look through the sub list and compate the values
#as we update our current max until we reach our basecase
findMax:
	subu	$sp, $sp, 32		#allocate storage for frame		
	sw	$ra, 20($sp)			#save return address
	sw	$fp, 16($sp)			#save frame pointer
	addu	$fp, $sp, 28		#reset frame pointer
	sw	$a1, 24($sp)			#save arguments	
	sw	$a2, 28($sp)		
	
	addi $t0, $zero, 4			#add 4 to $t0
	mul $t1, $a1, $t0			#compute address at $t1 x 4
	lw $t1, array($t1)
	sw $t1, 4($sp)				#stores array($t1) contents in stack
	
	mul $t2,$a2, $t0			#compute address at $t2 x 4
	lw $t2, array($t2)
	sw $t2, 8($sp)				#stores array($t2) contents in stack
	
	move $a1, $a2
	sub $a2, $a2, 1
	
	bgt $t1, $t2, returnOne		#$t1 > $t2; returnOne
	bgt $t2, $t1, returnTwo		#$t2 > $t1; returnTwo
#if (valOne > valTwo) we "return" valOne and update max	
returnOne:
	move $t3, $t1
	bgt $t3, $v1, update		#if possible, update the overall max
	j continue2
#if (valTwo > valOne) we "return" valTwo and update max	
returnTwo:
	move $t3, $t2
	bgt $t3, $v1, update		#if possible, update the overall max
	j continue2
#this updates our current maximum value that we will return
#I'm returning it in $v1 instead of $v0 because I use $v0 for
#syscalls
update:
	move $v1, $t3				#adjust the overall max
#continues to recursivly call, and then reloads the registers
continue2:
	jal	helper
# Reload registers
	lw	$ra, 20($sp)
	lw	$fp, 16($sp)
	addu	$sp, $sp, 32
	jr	$ra						#jump back to main's address
#----------------------------------------------------------------------------#
