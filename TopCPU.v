module cpu_top (
    input clk,                  // 时钟输入
    input reset,                // 重置信号
    output [31:0] pc,           // 当前指令地址（PC值）
    output [31:0] ir            // 指令暂存寄存器（IR值）
);
    wire [31:0] instruction;     // 指令
    wire [31:0] read_data1, read_data2, ALU_result;
    reg [31:0] write_data;       // 初始化为寄存器
    wire [31:0] immediate;       // 立即数
    wire [4:0] rs1, rs2, rd;     // 寄存器索引
    wire [6:0] opcode;           // 操作码
    wire [2:0] funct3;           // 功能码
    wire [6:0] funct7;           // 扩展功能码
    wire reg_write, mem_write, mem_read; // 控制信号
    wire [2:0] ALU_op;           // ALU操作码
    wire [31:0] next_PC;         // 下一个PC值
    reg [31:0] IR;               // 指令暂存寄存器
    wire branch;                 // 分支信号
    wire [31:0] ALU_B;           // ALU 的第二个操作数
    wire [31:0] read_data;       // 数据存储器读取数据
    wire load_from_dm;           // 新建变量，表示是否需要从数据存储器中读取

    // 初始化信号
    initial begin
        IR = 32'b0;
        write_data = 32'b0;
    end

    // PC模块
    PC pc_inst (
        .clk(clk),
        .reset(reset),
        .next_PC(next_PC),
        .PC(pc)
    );
    
    // 指令存储器
    Memory instruction_mem (
        .address(pc),
        .mem_read(1),    // 读取指令
        .mem_write(0),   // 不写内存
        .write_data(32'b0),
        .read_data(instruction)
    );

    // 数据存储器
    DataMemory data_mem (
        .address(ALU_result),
        .write_data(read_data2),
        .mem_read(load_from_dm),
        .mem_write((opcode == 7'b0100011)), // 只有在调用 SW 指令时才会写入内存
        .clk(clk),
        .reset(reset),
        .read_data(read_data)
    );


    // 寄存器堆
    Register_File reg_file (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU
    ALU alu_inst (
        .A(read_data1),
        .B(ALU_B), // 根据指令类型选择 ALU 的第二个操作数
        .ALU_op(ALU_op),
        .ALU_result(ALU_result)
    );

    // 控制单元
    Control_Unit control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .ALU_op(ALU_op),
        .branch(branch),
        .load_from_dm(load_from_dm) // 传递变量给控制单元
    );

    // 指令解码
    Instruction_Decode decode (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .immediate(immediate)
    );

    // 立即数生成模块
    Immediate_Generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    // 选择 ALU 的第二个操作数
    assign ALU_B = (opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b0100011) ? immediate : read_data2;

    // 连接其他模块和信号（例如指令解码，立即数生成等）
    assign next_PC = (branch && (read_data1 == read_data2)) ? pc + (immediate) : pc + 4; // 支持beq指令的PC更新逻辑

    

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            IR <= 32'b0;
            write_data <= 32'b0;
        end else begin
            IR <= instruction;
            if (reg_write) begin
                write_data <= (load_from_dm) ? read_data : ALU_result; // 将ALU结果或内存读取数据写入寄存器
            end
        end
    end

    assign ir = IR;

endmodule
