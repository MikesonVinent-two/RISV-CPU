module Memory (
    input [31:0] address,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    input reset,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:63]; // 256 bytes / 4 bytes per word = 64 words
    integer i;

    initial begin
        
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 32'b0; // 数据初始化
        end
    end
    
    always @(*) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1) begin
                memory[i] = 32'b0; // 数据初始化
            end
        end else begin
            if (mem_read) begin
                read_data = memory[address[31:2]]; // 以字为单位访问内存
            end
            if (mem_write) begin
                memory[address[31:2]] = write_data; // 以字为单位写入内存
            end
        end
    end
endmodule
