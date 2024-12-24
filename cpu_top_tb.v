module cpu_top_tb;
    reg clk;
    reg reset;
    wire [31:0] pc;
    wire [31:0] ir;

    // 实例化CPU顶层模块
    cpu_top uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .ir(ir)
    );

    // 初始化和仿真过程
    initial begin
        reset = 1;
        #3;
        reset = 0;

        // 初始化指令存储器和数据存储器
        uut.instruction_mem.memory[0] = 32'h00000000; // 空指令
        uut.instruction_mem.memory[1] = 32'h00800093; // addi x1, x0, 8
        uut.instruction_mem.memory[2] = 32'h0040a103; // lw x2, 4(x1)
        uut.instruction_mem.memory[3] = 32'h002081b3; // add x3, x1, x2
        uut.instruction_mem.memory[4] = 32'h40118233; // sub x4, x3, x1
        uut.instruction_mem.memory[5] = 32'h0040e2b3; // or x5, x1, x4
        uut.instruction_mem.memory[6] = 32'h0012e313; // ori x6, x5, 1
        uut.instruction_mem.memory[7] = 32'h00612023; // sw x6, 0(x2)
        uut.instruction_mem.memory[8] = 32'h004123b3; // slt x7, x2, x4
        uut.instruction_mem.memory[9] = 32'h00812413; // slti x8, x2, 8
        uut.instruction_mem.memory[10] = 32'hfe518ae3; // beq

        // 初始化数据存储器
        uut.data_mem.memory[0] = 8'h00; // 数据0
        uut.data_mem.memory[1] = 8'h01; // 数据1
        uut.data_mem.memory[2] = 8'h02; // 数据2
        uut.data_mem.memory[3] = 8'h03; // 数据3
        uut.data_mem.memory[4] = 8'h04; // 数据4
        uut.data_mem.memory[5] = 8'h05; // 数据5
        uut.data_mem.memory[6] = 8'h06; // 数据6
        uut.data_mem.memory[7] = 8'h07; // 数据7
        uut.data_mem.memory[8] = 8'h08; // 数据8
        uut.data_mem.memory[12] = 8'h04; // 数据12

        // 初始化剩余内存为空指令
        for (integer i = 11; i < 64; i = i + 1) begin
            uut.instruction_mem.memory[i] = 32'h00000000; // 填充空指令
        end

        // 仿真时间
        #200;

        // 结束仿真
        $stop;
    end

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期的时钟
    end

    // 监视信号
    initial begin
        $monitor("Time: %0t, PC: %h, IR: %h, Reg1: %h, Reg2: %h, Reg3: %h, ALU_result: %h", 
                 $time, pc, ir, uut.reg_file.registers[1], uut.reg_file.registers[2], uut.reg_file.registers[3], uut.alu_inst.ALU_result);
    end
endmodule
