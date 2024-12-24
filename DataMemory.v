module DataMemory (
    input [31:0] address,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    input clk,
    input reset,
    output reg [31:0] read_data
);
    reg [7:0] memory [0:255]; // 256 bytes
    integer i;

    initial begin
        // 初始化数据存储器（地址0~255）
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'b0; // 数据初始化
        end
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 8'b0; // 数据初始化
            end
        end else if (mem_write) begin
            memory[address] <= write_data[7:0]; // 写入第一个字节
            memory[address + 1] <= write_data[15:8]; // 写入第二个字节
            memory[address + 2] <= write_data[23:16]; // 写入第三个字节
            memory[address + 3] <= write_data[31:24]; // 写入第四个字节
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = {memory[address + 3], memory[address + 2], memory[address + 1], memory[address]}; // 读取四个字节并组合为32位
        end else begin
            read_data = 32'b0; // 如果不读取内存，则输出0
        end
    end
endmodule
