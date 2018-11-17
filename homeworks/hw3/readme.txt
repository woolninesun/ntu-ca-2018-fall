1.
    STEP1: open input file:
        # 因為使用 linux 系統，把 flags 調整成 0x0000
        li		$a1, 0x0000

    #STEP4: implement recursive function to solve the equation
        # 跳到計算 Recurrence 的 function, 執行完後直接跳到 result
        jal 	recu
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

    int revu ( int n, int n ):
        # 一開始將 $ra, n, c 存入 stack，在判斷 n == 1
        # 如果 n != 1，就繼續往下 call function，將回傳值存在 $s4
        # 最後 return 時將 $sp 恢復，在 j $ra 回去
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

2.
    $ echo "$(uname -o), $(uname -r)"
    > GNU/Linux, 4.18.16-arch1-1-ARCH
