.text
	li $v0,5
	syscall
	move $s0,$v0
	li $t1,4
	li $t2,100
	li $t3,400
	div $s0,$t3
	mfhi $t4	#result: year % 400
	beqz $t4, true
	
	div $s0,$t1
	mfhi $t4	#result: year % 4
	bnez $t4, false
	
	div $s0,$t2
	mfhi $t4	#result: year % 100
	beqz $t4,false
	j true
	
#true
true:
	li $a0,1
	li $v0,1
	syscall
	j end
#false
false:
	li $a0,0
	li $v0,1
	syscall
	j end
end:
	li $v0,10
	syscall