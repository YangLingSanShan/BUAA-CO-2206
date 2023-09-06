.data
matric: .space 256
str_enter:	.asciiz "\n"
str_space:	.asciiz " "

.macro find_position($ans,$i,$j)	#ans is the position of the element ans = (i*8+j)*4
	sll $ans,$i,3
	add $ans,$ans,$j
	sll $ans,$ans,2
.end_macro

.macro cin($des)
	li $v0,5 
	syscall
	move $des,$v0
.end_macro

.text
	cin($s0)			#horizontal
	cin($s1) 			#vertical
######in
	li $t0,0			#initiation
for_i_in_begin:
	beq $t0,$s0,for_i_in_end
	li $t1,0
for_j_in_begin:
	beq $t1,$s1,for_j_in_end
	li $v0 5
	syscall
	find_position($t2,$t0,$t1)	#store the element
	sw $v0 matric($t2)
	addi $t1,$t1,1
	j for_j_in_begin
for_j_in_end:
	addi $t0,$t0,1
	j for_i_in_begin
for_i_in_end:
######in_end

######out
	li $t0,0
for_i_out_begin:
	beq $t0,$s0,for_i_out_end
	li $t1,0
for_j_out_begin:
	beq $t1,$s1,for_j_out_end
	find_position($t2,$t0,$t1)
	
	lw $a0,matric($t2)
	li $v0,1
	syscall
	
	la  $a0, str_space
	li  $v0, 4
	syscall
	  
	addi $t1,$t1,1
	j for_j_out_begin
for_j_out_end:
	addi $t0,$t0,1
	
	la $a0 str_enter
	li $v0,4
	syscall
	
	j for_i_out_begin
for_i_out_end:
######out_end
	li $v0,10
	syscall
	