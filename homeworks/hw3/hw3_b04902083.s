.data
    n:
        .word	0
    c:
        .word	0
    comma:
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
        .byte	'0', '0', '0', '0'

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
# ($s1: n, $s2: c)

#   2 bytes for n
    li		$v0, 14					# 14 = read from file
    move	$a0, $s0				# $a0 <= fd_in
    la		$a1, n					# $a1 <= n
    li		$a2, 2					# read 2 byte to the address given by n
    syscall

#   1 byte for the comma
    li		$v0, 14					# 14 = read from file
    move	$a0, $s0				# $a0 <= fd_in
    la		$a1, comma				# $a1 <= comma
    li		$a2, 1					# read 1 bytes to the address given by comma
    syscall

#   2 bytes for c
    li		$v0, 14					# 14 = read from file
    move	$a0, $s0				# $a0 <= fd_in
    la		$a1, c					# $a1 <= c
    li		$a2, 2					# read 2 byte to the address given by c
    syscall

#STEP3: turn the chars into integers
    la		$a0, n
    bal		atoi
    move	$s1, $v0				# $s1 <= atoi(n)

    la		$a0, c
    bal		atoi
    move	$s2, $v0				# $s2 <= atoi(c)

# Inputs are ($s1: n, $s2: c)
# Output is $s3 (in integer)

#STEP4: implement recursive function to solve the equation
    jal 	recu
    j 		result

recu:
    #save in stack
    addi 	$sp, $sp, -8
    sw   	$ra, 0($sp)
    sw   	$s1, 4($sp)

    # if n == 1: return c
    addi 	$t0, $zero, 1
    beq  	$s1, $t0, recu.return

    # $s4 = recu(n/2, c)
    srl 	$s1, $s1, 1
    jal 	recu                    

    # $s4 = 2 * $s4 + c * n
    lw   	$s1, 4($sp)
    mult	$s2, $s1
    mflo 	$t1
    sll		$s4, $s4, 1 
    add 	$s4, $s4, $t1

recu.exit:
    lw      $ra, 0($sp)        		# read registers from stack
    addi    $sp, $sp, 8       		# bring back stack pointer
    jr      $ra

recu.return:
    add	    $s4, $zero, $s2
    j 		recu.exit

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
    li		$a2, 0644				# $a2 <= mode = 0
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
