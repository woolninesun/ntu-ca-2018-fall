.data
	input1:	
		.word	0	
	input2:	
		.word	0
	operater:	
		.word	0
	output:	
		.word	0

# TODO : change the file name/path to access the files
# NOTE : Before you submit the code,
# 		 make sure these two fields are "input.txt" and "output.txt"
	file_in:
		.asciiz	"input.txt"
	file_out:
		.asciiz	"output.txt"
		
# the following data is only for sample demonstration		
	output_ascii:	
		.byte	'X', 'X', 'X', 'X'

.text
	main:    						#start of your program

#STEP1: open input file
# ($s0: fd_in)

	li		$v0, 13					# 13 = open file
	la		$a0, file_in			# $a2 <= filepath
	
	# NOTE: this syscall is system-dependent
	# 0x4000 is _O_TEXT in Windows, but it's invalid in Linux
	# (io.h) for Windows, (fcntl-linux.h) for Linux
	# For Linux, 0x0000 (O_RDONLY) should be used instead
	li		$a1, 0x0000				# $a1 <= flags = 0x4000 for Windows, 0x0000 for Linux
	li		$a2, 0					# $a2 <= mode = 0
	syscall							# $v0 <= $s0 = fd
	move	$s0, $v0				# store fd_in in $s0,
									# fd_in is the file descriptor returned by syscall

#STEP2: read inputs (chars) from file to registers
# ($s1: input1, $s2: input2, $s3: operator)

#   2 bytes for the first operand
	li		$v0, 14					# 14 = read from file
	move	$a0, $s0				# $a0 <= fd_in
	la		$a1, input1				# $a1 <= input1
	li		$a2, 2					# read 2 bytes to the address given by input1
	syscall
	
#   1 byte for the operator
	li		$v0, 14					# 14 = read from file
	move	$a0, $s0				# $a0 <= fd_in
	la		$a1, operater			# $a1 <= operater
	li		$a2, 1					# read 1 bytes to the address given by operater
	syscall
	
#   2 bytes for the second operand
	li		$v0, 14					# 14 = read from file
	move	$a0, $s0				# $a0 <= fd_in
	la		$a1, input2				# $a1 <= input2
	li		$a2, 2					# read 2 bytes to the address given by input2
	syscall

#STEP3: turn the chars into integers
	la		$a0, input1		
	bal		atoi			 
	move	$s1, $v0				# $s1 <= atoi(input1)

	la		$a0, input2		
	bal		atoi			 
	move	$s2, $v0				# $s2 <= atoi(input2)

	lw		$s3, operater			# $s3 <= operater

# Inputs are ($s1: input1, $s2: input2, $s3: operator's ASCII)
# Output is $s4 (in integer)

#STEP4 integer operations
	beq     $s3, '+', addition
	beq     $s3, '-', substraction
	beq     $s3, '*', multiplication
	beq     $s3, '/', division
	j 		ret						# if $s3 == unsupport, goto ret

addition:
	add		$s4, $s1, $s2			# $s4 <= $s1 + $s2
	j 		result

substraction:
	sub		$s4, $s1, $s2			# $s4 <= $s1 - $s2
	j 		result

multiplication:
	mult 	$s1, $s2 				# $s1 * $s2
	mflo 	$s4 					# $s4 = LO
	j 		result

division:
	beq		$s1, 0, ret				# if $s1 == 0, goto ret
	div 	$s1, $s2				# $s1 / $s2
	mflo 	$s4 					# $s4 = LO
	j 		result

	
#STEP5: turn the integer into pritable char
    # transferred ASCII should be put into "output_ascii"
	# (see definition in the beginning of the file)
result:
	sw		$s4, output				# output <= $s4	
	move	$a0, $s4
	la		$a1, output_ascii
	bal		itoa					# itoa($s4, output_ascii)
	j		ret

ret:
#STEP6: write result (output_ascii) to file_out
# ($s4 = fd_out)
	
	li		$v0, 13					# 13 = open file
	la		$a0, file_out			# $a2 <= filepath
	li		$a1, 0x41				# $a1 <= flags = 0x4301 for Windows, 0x41 for Linux
	li		$a2, 0x1a4				# $a2 <= mode = 0
	syscall							# $v0 <= $s0 = fd_out
	move	$s4, $v0				# store fd_out in $s4
	
	li		$v0, 15					# 15 = write file
	move	$a0, $s4				# $a0 <= $s4 = fd_out
	la		$a1, output_ascii
	li		$a2, 4		
	syscall							# $v0 <= $s0 = fd
	
#STEP7: this is for you to debug your calculation on console
	li		$v0, 1					# 1 = print int
	lw		$a0, output				# $a0 <= $s1
	syscall							# print output


#STEP8: close file_in and file_out

	li		$v0, 16					# 16 = close file
	move	$a0, $s0				# $a0 <= $s0 = fd_in
	syscall							# close file

	li		$v0, 16					# 16 = close file
	move	$a0, $s4				# $a0 <= $s4 = fd_out
	syscall							# close file


# exit

	li		$v0, 10
	syscall



#######################################################################################
# int atoi ( const char *str );
atoi:
	or      $v0, $zero, $zero   	# num = 0
	or      $t1, $zero, $zero   	# isNegative = false
	lb      $t0, 0($a0)
	bne     $t0, '+', atoi.isp   	# consume a positive symbol
	addi    $a0, $a0, 1
atoi.isp:
	lb      $t0, 0($a0)
	bne     $t0, '-', atoi.num
	addi    $t1, $zero, 1       	# isNegative = true
	addi    $a0, $a0, 1
atoi.num:
	lb      $t0, 0($a0)
	slti    $t2, $t0, 58        	# *str <= '9'
	slti    $t3, $t0, '0'       	# *str < '0'
	beq     $t2, $zero, atoi.done
	bne     $t3, $zero, atoi.done
	sll     $t2, $v0, 1
	sll     $v0, $v0, 3
	add     $v0, $v0, $t2       	# num *= 10, using: num = (num << 3) + (num << 1)
	addi    $t0, $t0, -48
	add     $v0, $v0, $t0       	# num += (*str - '0')
	addi    $a0, $a0, 1         	# ++num
	j   	atoi.num
atoi.done:
	beq     $t1, $zero, atoi.out   	# if (isNegative) num = -num
	sub     $v0, $zero, $v0		
atoi.out:
	jr      $ra         			# return

# int itoa ( const int *num, char *str );
itoa:
	addi    $a1, $a1, 3				# $a1 += 3 ( $a1 = &$a1[3] )
	move   	$t0, $a1				# $t0 = $a1
	add		$t1, $zero, '0'			# $t1 = '0'
	li		$t2, 10					# $t2 = 10
itoa.set:
	sb     	$t1, 0($t0)				# $a1[i] = 0
	sub		$t3, $a1, $t0			# $t3 = &$a1[3] - &$a1[i] 
	beq     $t3, 3, itoa.str		# if $t3 == 3: jump to itoa.str
	sub   	$t0, $t0, 1				# $a1 = &$a1[i-1]
	j   	itoa.set
itoa.str:
	div 	$a0, $t2				# $a0 / 10
	mflo 	$a0 					# $a0 = LO - Quotient
	mfhi	$t3						# $t3 = HI - Remainder
	add		$t3, $t3, '0'			# convert $t3 to ascii
	sb     	$t3, 0($a1)				# $a1[i] = $t3
	sub     $a1, $a1, 1				# $a1 = &$a1[i-1]
	beq		$a0, $zero, itoa.out	# if $a0 == 0: jump to itoa.out
	j   	itoa.str
itoa.out:
	jr      $ra         			# return
