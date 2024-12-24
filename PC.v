module PC (
    input clk,
    input reset,
    input [31:0] next_PC,
    output reg [31:0] PC
);
    initial begin
        PC = 32'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'b0;
        end else begin
            PC <= next_PC;
        end
    end
endmodule
