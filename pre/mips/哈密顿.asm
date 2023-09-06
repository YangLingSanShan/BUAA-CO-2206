.data
	graph: .space 256
	book: .space 32

.macro push($des)
	subi $sp,$sp,4
	sw $des,0($sp)
.end_macro

.macro pop($des)
	lw $des,0($sp)
	addi $sp,$sp,4
.end_macro

.macro getInt($des)
	li $v0,5
	syscall
	move $des,$v0
.end_macro

.macro end
	li $v0,10
	syscall
.end_macro

.macro getPos($ans,$i,$j)	#ans=(i*8+j)*4
	sll $ans,$i,3
	add $ans,$ans,$j
	sll $ans,$ans,2
.end_macro



.text
	getInt($s0)		#n的值
	getInt($s1)		#m的值
	li $t0,0		#for 循环读入需要减1
for_begin:
	beq $t0,$s1,for_end
	getInt($t1)		#读入的第一个顶点
	getInt($t2)		#读入的第二个顶点
	subi $t1,$t1,1
	subi $t2,$t2,1
	
	getPos($t3,$t1,$t2)	#图的初始化
	li $v0,1
	sw $v0,graph($t3)
	getPos($t3,$t2,$t1)
	sw $v0,graph($t3)
	
	addi $t0,$t0,1
	j for_begin
for_end:
	li $t9,0
	jal dfs
end_function:

	li $v0,1
	syscall
	li $v0,10
	syscall	
	
	
	
dfs:
	push($ra)
	push($t4)
	push($t9)
	

	sll $t2,$t9,2
	li $t1,1
	sw $t1,book($t2)	#flag = t1 =1
	
	li $t0,0
	for_judge_begin:
		beq $t0,$s0,for_judge_end
		
		sll $t2,$t0,2
		lw $t3,book($t2)
		
		and $t1,$t1,$t3
		
		addi $t0,$t0,1
		j for_judge_begin
	for_judge_end:
	getPos($t2,$t9,$zero)
	lw $t3,graph($t2)
	and $t1,$t3,$t1				#flag && G[x][0]
	beqz $t1,continue_dfs
	
	li $a0,1
	j end_function
	
	continue_dfs:
	li $t4,0
	for_continue_begin:
		beq $t4,$s0,for_continue_end
		
		getPos($t2,$t9,$t4)
		lw $t3,graph($t2)
		
		sll $t2,$t4,2
		lw $t1,book($t2)
		
		xori $t1,$t1,1
		and $t1,$t1,$t3			#!book[i] && G[x][i]
		
		beq $t1,$zero,con
		

		move $t9,$t4
		jal dfs
		
		

					
	con:
		addi $t4,$t4,1
		j for_continue_begin
	for_continue_end:
	
	
	
	pop($t9)
	pop($t4)
	pop($ra)
	
	sll $t0,$t9,2
	sw $zero,book($t0)
	jr $ra
