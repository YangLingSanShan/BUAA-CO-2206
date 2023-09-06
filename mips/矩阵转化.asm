.data
	matrix: .space 10000
	str_space: .asciiz " "
	str_enter: .asciiz "\n"
	
.macro getindex($ans,$i,$j)	#ans= (50*i+j)*4
	li $t9,50
	mult $i,$t9
	mflo $t9
	add $ans,$t9,$j
	sll $ans,$ans,2
.end_macro

.text
	li $v0,5
	syscall
	move $s0,$v0	#s0 to save i
	li $v0,5
	syscall
	move $s1,$v0	#s1 to save j
#二重循环读入
	li $t0,0
for_i_begin:
	beq $t0,$s0,for_i_end
	li $t1,0
for_j_begin:
	beq $t1,$s1,for_j_end
	
	li $v0,5
	syscall
	getindex($t2,$t0,$t1)
	sw $v0,matrix($t2)
	
	addi $t1,$t1,1
	j for_j_begin
for_j_end:
	addi $t0,$t0,1
	j for_i_begin
for_i_end:


	move $t0,$s0	#t0=i
	subi $t0,$t0,1	#t0=i-1
for_i_read_begin:
	bltz $t0,for_i_read_end
	
	move $t1,$s1	#t1=j
	subi $t1,$t1,1	#t1=j-1
for_j_read_begin:
	bltz $t1,for_j_read_end
	
	getindex($t2,$t0,$t1)
	lw $a0,matrix($t2)
	
	jal judge
	
	subi $t1,$t1,1
	j for_j_read_begin
for_j_read_end:
	subi $t0,$t0,1
	j for_i_read_begin
for_i_read_end:
	li $v0,10
	syscall
	
judge:
	beqz $a0,judge_end
	
	move $t3,$a0
	
	move $a0,$t0
	addi $a0,$a0,1
	li $v0, 1
	syscall
	
	la $a0,str_space
	li $v0,4
	syscall
	
	move $a0,$t1
	addi $a0,$a0,1
	li $v0,1
	syscall
	
	la $a0,str_space
	li $v0,4
	syscall
	
	move $a0,$t3
	li $v0,1
	syscall
	
	la $a0,str_enter
	li $v0,4
	syscall
	
		
	judge_end:
		jr $ra
