	.data
	Array:	.word 13, 43, 16, 23, 9, 2, 15, 19, 8, 28, 30, 4, 48, 24, 10, 18, 29, 35, 6, 35
	buf: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.text
main:
	la $a0, Array 	# take array
	li $a1, 0		# left
	li $a2, 19		# right
prepare:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 8($sp)	# save address of array
	sw $a1, 4($sp)	
	sw $a2, 0($sp)
	jal mergesort
print:
	la $a0, Array
	addi $t2, $a0, 80	# end of A
	move $t1, $a0
loopprint:
	#print A[i]
	li $v0, 1
	lw $a0, 0($t1)
	syscall
	#print space
	li $v0, 11
	la $a0, 32
	syscall

	addi $t1, $t1, 4
	bne $t1, $t2, loopprint
end:
	li $v0, 10
	syscall
mergesort:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)
	move $s1, $a0	#A[]
	move $s2, $a1	#left
	move $s3, $a2	#right
	slt $t0, $s2, $s3
	bne $t0, $zero, inif
	j done
inif:
	add $s4, $s3, $s2	# left + right
	srl $s4, $s4, 1		# mid = (left + right) / 2
	move $a1, $s2
	move $a2, $s4	# right <- mid
	jal mergesort	# mergesort(A, left, mid)
	addi $t4, $s4, 1	# mid + 1
	move $a2, $s3
	move $a1, $t4		# left <- mid + 1
	jal mergesort		# mergesort(A, mid + 1, right)
	move $a0, $s1	# array
	move $a1, $s2	# left
	move $a2, $s4	# mid
	move $a3, $s3	# right
	jal merge 		#merge(A, left, mid, right)
done:
	lw $ra, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	lw $s3, 4($sp)
	lw $s4, 0($sp)
	addi $sp, $sp, 20
	jr $ra		# jump register
merge:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)

	move $s1, $a1	#left
	move $s2, $a2	#mid
	move $s3, $a3	#right
	move $t0, $s1	# i = left
for:
	slt $t1, $s3, $t0	# i > right
	bne $t1, $zero, out
	sll $t1, $t0, 2		# left * 4
	la $s4, Array
	add $t2, $s4, $t1	
	la $s5, buf			
	add $t3, $s5, $t1
	lw $t4, 0($t2)
	sw $t4, 0($t3)		#buf[i] = A[i]
	addi $t0, $t0, 1
	j for
out:
	move $t0, $s1	# i = left
	move $t1, $s1	# left_i = left
	move $t2, $s2	
	addi $t2, $t2, 1	# right_ = mid + 1
while1:
	slt $t4, $s2, $t1
	bne $t4, $zero, while3
	slt $t5, $s3, $t2
	bne $t5, $zero, while2	#condition for while
	sll $t7, $t1, 2		# left_i * 4
	la $t3, buf
	add $t6, $t3, $t7	# buf[left_i]
	lw $t8, 0($t6)		# In $t8, there is buf[left_i]
	sll $t7, $t2, 2
	add $t7, $a0, $t7
	lw $t4, 0($t7)		#in $t4, there is buf[right_i]
	slt $t6, $t8, $t4
	beq $t6, $zero, second
	sll $t4, $t0, 2		# i * 4
	la $a0, Array
	add $t4, $t4, $a0
	sw $t8, 0($t4)		# A[i] = buf[left_i]
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	j while1
second:
	sll $t3, $t0, 2		
	la $t4, Array 	
	add $t3, $t3, $t4
	la $t4, buf
	sll $t5, $t2, 2
	add $t4, $t4, $t5
	lw $t6, 0($t4)
	sw $t6, 0($t3)		# A[i] = buf[right_i]
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	j while1
#	while(left_i <= mid)
while2:
	slt $t4, $s2, $t1
	bne $t4, $zero, while3	# condition for while
	sll $t3, $t0, 2		# i * 4
	la $t5, Array			
	add $t3, $t3, $t5
	sll $t4, $t1, 2
	la $t5, buf
	add $t4, $t4, $t5	
	lw $t6, 0($t4)		# A[i] = buf[left_i]
	sw $t6, 0($t3)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j while2
#	while(right_i <= right)
while3:
	slt $t4, $s3, $t2
	bne $t4, $zero, done
	sll $t3, $t0, 2
	la $t5, Array
	add $t3, $t3, $t5
	sll $t4, $t2, 2
	la $t6, buf
	add $t4, $t4, $t6
	lw $t6, 0($t4)
	sw $t6, 0($t3)
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	j while3

