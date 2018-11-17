1.
    STEP1: open input file:
        # 因為使用 linux 系統，把 flags 調整成 0x0000
        li		$a1, 0x0000

    STEP4 integer operations:
        # 直接對 $s3 (operater) 做判斷，跳到做運算的地方
        beq     $s3, '+', addition
        beq     $s3, '-', substraction
        beq     $s3, '*', multiplication
        beq     $s3, '/', division
	    j 		ret						    # if $s3 == unsupport, goto ret

        # 每個運算做對應的指令操作，將結果存入 $s4
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
        
    STEP5: turn the integer into pritable char:
        # 將 $s0 存入 output, output_ascii 位置存入 $a1(arg1)
        result:
            sw		$s4, output				# output <= $s4	
            move	$a0, $s4
            la		$a1, output_ascii
            bal		itoa					# itoa($s4, output_ascii)
            j		ret

    STEP6: write result (output_ascii) to file_out
        # 因為使用 linux 系統，把 flags 調整成 0x41
            li		$a1, 0x41				# $a1 <= flags = 0x41 for linux

    int itoa ( const int *num, char *str ):
        # 一開始就先把指標指到 str 的最後一個位置，方便從低位開始放
        # 把 *str 全部設成 '0', 然後在慢慢用迴圈將每個位數轉成 ascii
        itoa:
            addi    $a1, $a1, 3				# $a1 += 3 ( $a1 = &$a1[3] )
            move   	$t0, $a1				# $t0 = $a1
            add		$t1, $zero, '0'			# $t1 = '0'
            addi	$t2, $zero, 10			# $t2 = 10
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

2.
    $ echo "$(uname -o), $(uname -r)"
    > GNU/Linux, 4.18.11-arch1-1-ARCH
