module Control_Unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg reg_write,
    output reg mem_write,
    output reg mem_read,
    output reg [2:0] ALU_op,
    output reg branch,
    output reg load_from_dm // 新建变量，表示是否需要从数据存储器中读取
);
    initial begin
        reg_write = 0;
        mem_write = 0;
        mem_read = 0;
        ALU_op = 3'b000;
        branch = 0;
        load_from_dm = 0; // 初始化变量
    end

    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                load_from_dm = 0; // 不需要从数据存储器中读取
                case (funct3)
                    3'b000: ALU_op = (funct7 == 7'b0000000) ? 3'b000 : 3'b001; // add/sub
                    3'b111: ALU_op = 3'b100; // and
                    3'b110: ALU_op = 3'b010; // or
                    3'b100: ALU_op = 3'b101; // xor
                    3'b001: ALU_op = 3'b110; // sll
                    3'b101: ALU_op = (funct7 == 7'b0000000) ? 3'b111 : 3'b011; // srl/sra
                    3'b010: ALU_op = 3'b011; // slt
                    default: ALU_op = 3'b000;
                endcase
                branch = 0;
            end
            7'b0000011: begin // I-type (LW)
                reg_write = 1;
                mem_write = 0;
                mem_read = 1;
                load_from_dm = 1; // 需要从数据存储器中读取
                ALU_op = 3'b000; // 加法
                branch = 0;
            end
            7'b0100011: begin // S-type (SW)
                reg_write = 0;
                mem_write = 1;
                mem_read = 0;
                load_from_dm = 0; // 不需要从数据存储器中读取
                ALU_op = 3'b000; // 加法
                branch = 0;
            end
            7'b1100011: begin // B-type (BEQ)
                reg_write = 0;
                mem_write = 0;
                mem_read = 0;
                load_from_dm = 0; // 不需要从数据存储器中读取
                ALU_op = 3'b001; // 减法
                branch = (funct3 == 3'b000); // 仅在funct3为000时为beq指令
            end
            7'b0010011: begin // I-type (addi, ori, slti)
                reg_write = 1;
                mem_write = 0;
                mem_read = 0;
                load_from_dm = 0; // 不需要从数据存储器中读取
                case (funct3)
                    3'b000: ALU_op = 3'b000; // addi
                    3'b110: ALU_op = 3'b010; // ori
                    3'b010: ALU_op = 3'b011; // slti
                    default: ALU_op = 3'b000;
                endcase
                branch = 0;
            end
            // 添加其他指令的控制逻辑
            default: begin
                reg_write = 0;
                mem_write = 0;
                mem_read = 0;
                load_from_dm = 0; // 不需要从数据存储器中读取
                ALU_op = 3'b000;
                branch = 0;
            end
        endcase
    end
endmodule
