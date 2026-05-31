module data_memory(
    input  wire        clk,
    input  wire        memread,
    input  wire        memwrite,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);
 
    // 256 memory locations, each 32 bits wide
    // Total = 256 x 4 bytes = 1KB
    reg [31:0] memory [0:255];
 
    // Write - sequential, on rising clock edge
    always @(posedge clk) 
    begin
        if (memwrite)
            memory[address[31:2]] <= write_data;
    end
 
    // Read - combinational, instant
    always @(*) 
    begin
        if (memread)
            read_data = memory[address[31:2]];
        else
            read_data = 32'b0;
    end
 
endmodule
