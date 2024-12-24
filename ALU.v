module ALU (
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALU_op,
    output reg [31:0] ALU_result
);
    initial begin
        ALU_result = 32'b0;
    end

    always @(*) begin
        case (ALU_op)
            3'b000: ALU_result = A + B; // add, addi
            3'b001: ALU_result = A - B; // sub
            3'b010: ALU_result = A | B; // or, ori
            3'b011: ALU_result = (A < B) ? 32'b1 : 32'b0; // slt, slti
            3'b100: ALU_result = A & B; // 逻辑与
            3'b101: ALU_result = A ^ B; // 逻辑异或
            3'b110: ALU_result = A << B[4:0]; // 左移
            3'b111: ALU_result = A >> B[4:0]; // 右移
            default: ALU_result = 32'b0;
        endcase
    end
endmodule
