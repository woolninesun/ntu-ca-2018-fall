---
export_on_save:
  phantomjs: "pdf"
---
# Computer Architecture 2018 Fall
<p style="text-align: right;">b04902083 資工四 莊翔旭</p>

1. Coding Environment
    ```bash
    $ echo "$(uname -o), $(uname -r)"
    GNU/Linux, 4.18.16-arch1-1-ARCH
    ```

    附上 makefile 表示編譯和執行的指令。

2. Module implementation explanation
    * testbench.v, PC.v, Registers.v, Instruction_Memory.v: 沒改太多東西
    * CPU.v: 根據 spec 的 datapath 就知道 cpu.v 裡面每個模組的資料流
        @import "./datapath.pdf"
    * Adder.v: PC += 4
    * Control.v: 從 instruction[6:0] 判斷 instruction type 且輸出控制流
    * ALU_Control.v: 從 funct 和 aluop 去判斷 alu 要執行什麼運算
    * Sign_Extend.v: 將 imm12 Sign Extend 成 32 bits
    * ALU.v: 根據 alu_ctrl 去將 data1_i 和 data2_i 做運算並輸出到 alu_result
    * MUX32.v: 如果 select 是 1 輸出 data2, 反之輸出 data1
